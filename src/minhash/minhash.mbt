// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// MinHash signature representation storing k minimum hash values.
pub struct MinHashSignature {
  num_hashes : Int
  values : Array[UInt]
}

///|
pub fn MinHashSignature::new(num_hashes : Int) -> MinHashSignature {
  let values = Array::new(capacity=num_hashes)
  for i = 0; i < num_hashes; i = i + 1 {
    values.push(0xffffffffU)
  }
  { num_hashes, values }
}

///|
pub fn MinHashSignature::from_values(values : Array[UInt]) -> MinHashSignature {
  { num_hashes: values.length(), values }
}

///|
/// Updates signature with a raw uint token value using universal hash family.
pub fn MinHashSignature::update_hash_family(
  self : MinHashSignature,
  token : UInt,
  hash_family : Array[@hash.UniversalHash],
) -> Unit {
  let len = self.num_hashes
  for i = 0; i < len; i = i + 1 {
    let h_val = hash_family[i].hash_uint(token)
    if h_val < self.values[i] {
      self.values[i] = h_val
    }
  }
}

///|
/// Calculates estimated Jaccard Similarity between two MinHash signatures.
/// Sim(A, B) = count(A[i] == B[i]) / k
pub fn jaccard_similarity(
  sig_a : MinHashSignature,
  sig_b : MinHashSignature,
) -> Double {
  let len = sig_a.num_hashes
  if len != sig_b.num_hashes || len == 0 {
    return 0.0
  }

  let mut matches = 0
  for i = 0; i < len; i = i + 1 {
    if sig_a.values[i] == sig_b.values[i] {
      matches = matches + 1
    }
  }

  matches.to_double() / len.to_double()
}

///|
/// Merges two MinHash signatures (component-wise minimum).
pub fn merge_signatures(
  sig_a : MinHashSignature,
  sig_b : MinHashSignature,
) -> MinHashSignature {
  let len = sig_a.num_hashes
  let result = MinHashSignature::new(len)
  for i = 0; i < len; i = i + 1 {
    let v_a = sig_a.values[i]
    let v_b = sig_b.values[i]
    result.values[i] = if v_a < v_b { v_a } else { v_b }
  }
  result
}

///|
/// MinHasher engine configured with number of permutations and seed.
pub struct MinHasher {
  num_hashes : Int
  seed : UInt64
  hash_family : Array[@hash.UniversalHash]
  shingle_builder : @tokenizer.ShingleBuilder
}

///|
pub fn MinHasher::new(num_hashes : Int, seed : UInt64) -> MinHasher {
  let hash_family = @hash.generate_hash_family(num_hashes, seed)
  let shingle_builder = @tokenizer.ShingleBuilder::new(3, seed.to_uint())
  { num_hashes, seed, hash_family, shingle_builder }
}

///|
/// Computes MinHash signature for an array of UInt token values.
pub fn MinHasher::compute_tokens(
  self : MinHasher,
  tokens : Array[UInt],
) -> MinHashSignature {
  let sig = MinHashSignature::new(self.num_hashes)
  for i = 0; i < tokens.length(); i = i + 1 {
    sig.update_hash_family(tokens[i], self.hash_family)
  }
  sig
}

///|
/// Computes MinHash signature for document string.
pub fn MinHasher::compute_text(
  self : MinHasher,
  text : String,
) -> MinHashSignature {
  let tokens = self.shingle_builder.build_hashed_shingles(text)
  self.compute_tokens(tokens)
}
