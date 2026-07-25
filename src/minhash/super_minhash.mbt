// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

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
  let sig = MinHashSignature::new(m)

  for i = 0; i < tokens.length(); i = i + 1 {
    let token = tokens[i]
    for j = 0; j < m; j = j + 1 {
      let hash_input = token ^
        (j.reinterpret_as_uint() * 0x9e3779b9U + self.seed)
      let val = @hash.murmurhash3_32_str(hash_input.to_string(), self.seed)
      if val < sig.values[j] {
        sig.values[j] = val
      }
    }
  }

  sig
}
