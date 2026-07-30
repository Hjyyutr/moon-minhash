// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
priv struct Pcg {
  mut state : UInt64
  inc : UInt64
}

///|
fn Pcg::new(state : UInt64, inc : UInt64) -> Pcg {
  { state: state + inc, inc: inc | 1UL }
}

///|
fn Pcg::next(self : Pcg) -> UInt {
  let old = self.state
  self.state = old * 6364136223846793005UL + self.inc
  let xorshifted = (((old >> 18) ^ old) >> 27).to_uint()
  let rot = (old >> 59).to_uint()
  let rot_int = rot.reinterpret_as_int()
  let right_shift = rot_int
  let left_shift = (32 - rot_int) & 31
  (xorshifted >> right_shift) | (xorshifted << left_shift)
}

///|
fn uint_to_double(val : UInt) -> Double {
  let val_i = val.reinterpret_as_int()
  if val_i >= 0 {
    val_i.to_double()
  } else {
    val_i.to_double() + 4294967296.0
  }
}

///|
fn pack_rj(j : Int, r : Double) -> UInt {
  let j_u = j.reinterpret_as_uint()
  let r_u = (r * 65536.0).to_uint() & 0xffffU
  (j_u << 16) | r_u
}

///|
/// SuperMinHash algorithm implementation.
/// Computes hyper-dense MinHash signatures in fast single-pass time.
pub struct SuperMinHasher {
  num_hashes : Int
  seed : UInt
}

///|
pub fn SuperMinHasher::new(num_hashes : Int, seed : UInt) -> SuperMinHasher {
  { num_hashes, seed }
}

///|
pub fn SuperMinHasher::compute(
  self : SuperMinHasher,
  tokens : Array[UInt],
) -> MinHashSignature {
  let m = self.num_hashes
  let values = Array::make(m, 0xffffffffU)
  let p = Array::make(m, 0)
  let q = Array::make(m, -1)
  let b = Array::make(m, 0)
  for idx = 0; idx < m; idx = idx + 1 {
    p[idx] = idx
  }
  b[m - 1] = m

  let mut state_i = 0
  let mut state_a = m - 1

  for idx = 0; idx < tokens.length(); idx = idx + 1 {
    let token = tokens[idx]

    // Create token_bytes using immutable makei with type annotations.
    let token_bytes = Bytes::makei(4, fn(idx : Int) -> Byte {
      if idx == 0 {
        (token & 0xffU).to_byte()
      } else if idx == 1 {
        ((token >> 8) & 0xffU).to_byte()
      } else if idx == 2 {
        ((token >> 16) & 0xffU).to_byte()
      } else {
        ((token >> 24) & 0xffU).to_byte()
      }
    })

    let d = @hash.siphash24(token_bytes, self.seed.to_uint64(), 0x9e3779b9UL)
    let rnd = Pcg::new(d, 0UL)

    for j = 0; j < state_a; j = j + 1 {
      let u = (uint_to_double(rnd.next()) + 0.5) / 4294967296.0
      let offset = rnd.next() % (m - j).reinterpret_as_uint()
      let k = j + offset.reinterpret_as_int()

      if q[j] != state_i {
        q[j] = state_i
        p[j] = j
      }
      if q[k] != state_i {
        q[k] = state_i
        p[k] = k
      }

      // Swap p[j] and p[k]
      let tmp = p[j]
      p[j] = p[k]
      p[k] = tmp

      let rj_packed = pack_rj(j, u)
      let pj = p[j]
      if rj_packed < values[pj] {
        let jc_unpacked = (values[pj] >> 16).reinterpret_as_int()
        let jc = if jc_unpacked > m - 1 { m - 1 } else { jc_unpacked }
        values[pj] = rj_packed
        if j < jc {
          b[jc] = b[jc] - 1
          b[j] = b[j] + 1
          while b[state_a] == 0 {
            state_a = state_a - 1
          }
        }
      }
    }
    state_i = state_i + 1
  }

  MinHashSignature::from_values(values)
}
