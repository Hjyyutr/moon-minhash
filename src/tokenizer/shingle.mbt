// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Shingle Builder for generating hashed k-shingles from text sets.
pub struct ShingleBuilder {
  shingle_size : Int
  tokenizer_type : TokenizerType
  seed : UInt
}

///|
pub fn ShingleBuilder::new(shingle_size : Int, seed : UInt) -> ShingleBuilder {
  { shingle_size, tokenizer_type: CharNGram(shingle_size), seed }
}

///|
/// Extracts hashed 32-bit uint set of shingles from document text.
pub fn ShingleBuilder::build_hashed_shingles(
  self : ShingleBuilder,
  text : String,
) -> Array[UInt] {
  let tokens = tokenize(text, self.tokenizer_type)
  let result = Array::new(capacity=tokens.length())
  let seen = Map::from_array([])

  for i = 0; i < tokens.length(); i = i + 1 {
    let hash_val = @hash.murmurhash3_32_str(tokens[i], self.seed)
    if !seen.contains(hash_val) {
      seen.set(hash_val, true)
      result.push(hash_val)
    }
  }
  result
}

///|
/// Extracts string shingles from text.
pub fn ShingleBuilder::build_string_shingles(
  self : ShingleBuilder,
  text : String,
) -> Array[String] {
  tokenize(text, self.tokenizer_type)
}
