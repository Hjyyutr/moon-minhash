// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// FNV-1a 32-bit non-cryptographic hash function.
pub fn fnv1a_32(bytes : Bytes) -> UInt {
  let prime : UInt = 16777619U
  let mut hash : UInt = 2166136261U
  let len = bytes.length()
  for i = 0; i < len; i = i + 1 {
    hash = hash ^ bytes[i].to_uint()
    hash = hash * prime
  }
  hash
}

///|
/// FNV-1a 32-bit helper for strings.
pub fn fnv1a_32_str(str : String) -> UInt {
  fnv1a_32(@utf8.encode(str))
}

///|
/// FNV-1a 64-bit non-cryptographic hash function.
pub fn fnv1a_64(bytes : Bytes) -> UInt64 {
  let prime : UInt64 = 1099511628211UL
  let mut hash : UInt64 = 14695981039346656037UL
  let len = bytes.length()
  for i = 0; i < len; i = i + 1 {
    hash = hash ^ bytes[i].to_uint64()
    hash = hash * prime
  }
  hash
}

///|
/// FNV-1a 64-bit helper for strings.
pub fn fnv1a_64_str(str : String) -> UInt64 {
  fnv1a_64(@utf8.encode(str))
}
