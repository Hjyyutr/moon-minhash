// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Universal Hash Function for linear permutation in MinHash.
/// Formula: h(x) = ((a * x + b) mod P) mod M
/// P is a Mersenne prime (2^31 - 1 = 2147483647).
pub struct UniversalHash {
  a : UInt64
  b : UInt64
}

///|
let prime_p : UInt64 = 2147483647UL

///|
/// Creates a new UniversalHash with multiplier `a` and offset `b`.
pub fn UniversalHash::new(a : UInt64, b : UInt64) -> UniversalHash {
  let valid_a = if a == 0UL { 1UL } else { a % prime_p }
  let valid_b = b % prime_p
  { a: valid_a, b: valid_b }
}

///|
/// Hashes a 64-bit unsigned integer value.
pub fn UniversalHash::hash(self : UniversalHash, x : UInt64) -> UInt64 {
  let val = (self.a * (x % prime_p) + self.b) % prime_p
  val
}

///|
/// Hashes a 32-bit unsigned integer value to UInt.
pub fn UniversalHash::hash_uint(self : UniversalHash, x : UInt) -> UInt {
  let x64 = x.to_uint64()
  let res = self.hash(x64)
  res.to_uint()
}

///|
/// Generator for family of N linear universal hash functions with reproducible random seeds.
pub fn generate_hash_family(
  num_hashes : Int,
  seed : UInt64,
) -> Array[UniversalHash] {
  let result = Array::new(capacity=num_hashes)
  let mut current_seed = seed
  let mul : UInt64 = 6364136223846793005UL
  let add : UInt64 = 1442695040888963407UL
  for i = 0; i < num_hashes; i = i + 1 {
    current_seed = current_seed * mul + add
    let a = (current_seed >> 1) % prime_p
    current_seed = current_seed * mul + add
    let b = current_seed % prime_p
    result.push(UniversalHash::new(a, b))
  }
  result
}
