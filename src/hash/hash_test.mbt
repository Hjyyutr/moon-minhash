// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
test "test uint64 literal" {
  let a : UInt64 = 2147483647UL
  let b : UInt64 = 0x736f6d6570736575UL
  let c : UInt64 = 100UL
  let d : UInt = 100U
  let _ = a + b + c + d.to_uint64()
}

///|
test "fnv1a 32-bit and 64-bit hashing" {
  let h32 = fnv1a_32_str("moonbit")
  let h64 = fnv1a_64_str("moonbit")
  assert_true(h32 != 0U)
  assert_true(h64 != 0UL)

  // FNV-1a is deterministic
  assert_eq(fnv1a_32_str("moonbit"), h32)
  assert_eq(fnv1a_64_str("moonbit"), h64)
}

///|
test "murmurhash3 and xxhash verification" {
  let h_m = murmurhash3_32_str("hello", 123U)
  let h_x = xxhash32_str("hello", 123U)
  assert_true(h_m != 0U)
  assert_true(h_x != 0U)
}

///|
test "siphash24 determinism and collision resistance" {
  let bytes1 = @utf8.encode("moonbit")
  let bytes2 = @utf8.encode("MoonBit")
  let bytes3 = @utf8.encode("moonbit")

  let h1 = siphash24(bytes1, 0UL, 0UL)
  let h2 = siphash24(bytes2, 0UL, 0UL)
  let h3 = siphash24(bytes3, 0UL, 0UL)

  // Determinism: same input -> same output
  assert_eq(h1, h3)
  // Collision resistance: different input -> different output (with high probability)
  assert_true(h1 != h2)

  // Different keys -> different output
  let h4 = siphash24(bytes1, 1UL, 0UL)
  assert_true(h1 != h4)
}
