// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

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
/// Computes weighted MinHash signature for weighted element array.
pub fn compute_weighted_minhash(
  elements : Array[WeightedElement],
  num_hashes : Int,
  seed : UInt,
) -> WeightedMinHashSignature {
  let sig = WeightedMinHashSignature::new(num_hashes)

  for i = 0; i < elements.length(); i = i + 1 {
    let elem = elements[i]
    if elem.weight <= 0.0 {
      continue
    }

    for j = 0; j < num_hashes; j = j + 1 {
      let hash_seed = seed + (j * 10007).reinterpret_as_uint()
      let h = @hash.murmurhash3_32_str(elem.id.to_string(), hash_seed)
      let sample_val = (h.to_double() + 1.0) / elem.weight
      if sample_val < sig.k_vals[j] {
        sig.k_vals[j] = sample_val
        sig.k_ids[j] = elem.id
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
    if sig_a.k_ids[i] == sig_b.k_ids[i] {
      matches = matches + 1
    }
  }

  matches.to_double() / n.to_double()
}
