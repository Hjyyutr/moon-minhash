// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
fn ln(x : Double) -> Double {
  if x <= 0.0 {
    return 0.0
  }
  let mut val = x
  let mut e = 0
  while val > 1.4142135623730951 {
    val = val / 2.0
    e = e + 1
  }
  while val < 0.7071067811865475 {
    val = val * 2.0
    e = e - 1
  }
  let z = (val - 1.0) / (val + 1.0)
  let z2 = z * z
  let approx = 2.0 *
    z *
    (
      1.0 +
      z2 *
      (
        1.0 / 3.0 +
        z2 *
        (
          1.0 / 5.0 +
          z2 *
          (
            1.0 / 7.0 +
            z2 *
            (
              1.0 / 9.0 +
              z2 * (1.0 / 11.0 + z2 * (1.0 / 13.0 + z2 * (1.0 / 15.0)))
            )
          )
        )
      )
    )
  approx + e.to_double() * 0.6931471805599453
}

///|
/// Consistent Weighted Sampling (CWS) for Weighted MinHash set calculation.
pub struct WeightedElement {
  id : UInt
  weight : Double
}

///|
pub fn WeightedElement::new(id : UInt, weight : Double) -> WeightedElement {
  { id, weight }
}

///|
pub struct WeightedMinHashSignature {
  num_hashes : Int
  k_ids : Array[UInt]
  k_vals : Array[Double]
}

///|
pub fn WeightedMinHashSignature::new(
  num_hashes : Int,
) -> WeightedMinHashSignature {
  let ids = Array::new(capacity=num_hashes)
  let vals = Array::new(capacity=num_hashes)
  for i = 0; i < num_hashes; i = i + 1 {
    ids.push(0U)
    vals.push(1.0e18)
  }
  { num_hashes, k_ids: ids, k_vals: vals }
}

///|
/// Computes weighted MinHash signature using Ioffe's Consistent Weighted Sampling (ICWS).
pub fn compute_weighted_minhash(
  elements : Array[WeightedElement],
  num_hashes : Int,
  seed : UInt,
) -> WeightedMinHashSignature {
  let sig = WeightedMinHashSignature::new(num_hashes)
  let min_ln_a = Array::make(num_hashes, 1.0e18)

  for i = 0; i < elements.length(); i = i + 1 {
    let elem = elements[i]
    if elem.weight <= 0.0 {
      continue
    }

    let vlog = ln(elem.weight)
    let elem_bytes = Bytes::makei(4, fn(idx : Int) -> Byte {
      if idx == 0 {
        (elem.id & 0xffU).to_byte()
      } else if idx == 1 {
        ((elem.id >> 8) & 0xffU).to_byte()
      } else if idx == 2 {
        ((elem.id >> 16) & 0xffU).to_byte()
      } else {
        ((elem.id >> 24) & 0xffU).to_byte()
      }
    })

    for j = 0; j < num_hashes; j = j + 1 {
      // Seed Pcg with hash(j, elem.id, seed)
      let hash_seed = @hash.siphash24(
        elem_bytes,
        seed.to_uint64() + j.to_uint64(),
        0x9e3779b9UL,
      )
      let rnd = Pcg::new(hash_seed, 0UL)

      let u1 = (uint_to_double(rnd.next()) + 0.5) / 4294967296.0
      let u2 = (uint_to_double(rnd.next()) + 0.5) / 4294967296.0
      let r = -ln(u1 * u2)

      let u3 = (uint_to_double(rnd.next()) + 0.5) / 4294967296.0
      let u4 = (uint_to_double(rnd.next()) + 0.5) / 4294967296.0
      let c = -ln(u3 * u4)
      let ln_cs = ln(c)

      let beta = (uint_to_double(rnd.next()) + 0.5) / 4294967296.0

      let t = (vlog / r + beta).floor()
      let ln_y = (t - beta) * r
      let ln_a = ln_cs - ln_y - r

      if ln_a < min_ln_a[j] {
        min_ln_a[j] = ln_a
        sig.k_ids[j] = elem.id
        sig.k_vals[j] = t
      }
    }
  }

  sig
}

///|
/// Computes weighted Jaccard similarity between two Weighted MinHash signatures.
pub fn weighted_jaccard_similarity(
  sig_a : WeightedMinHashSignature,
  sig_b : WeightedMinHashSignature,
) -> Double {
  if sig_a.num_hashes != sig_b.num_hashes || sig_a.num_hashes == 0 {
    return 0.0
  }

  let mut matches = 0
  let n = sig_a.num_hashes
  for i = 0; i < n; i = i + 1 {
    if sig_a.k_ids[i] == sig_b.k_ids[i] && sig_a.k_vals[i] == sig_b.k_vals[i] {
      matches = matches + 1
    }
  }

  matches.to_double() / n.to_double()
}
