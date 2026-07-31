// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
test "fnv1a 32-bit standard test vectors" {
  // Empty string vector
  let h_empty = fnv1a_32_str("")
  assert_eq(h_empty, 2166136261U)

  // "a" vector
  let h_a = fnv1a_32_str("a")
  assert_eq(h_a, 3826002220U)

  // Determinism check
  assert_eq(fnv1a_32_str("moonbit"), fnv1a_32_str("moonbit"))
  assert_true(fnv1a_32_str("moonbit") != fnv1a_32_str("MoonBit"))
}

///|
test "fnv1a 64-bit standard test vectors" {
  // Empty string vector
  let h_empty = fnv1a_64_str("")
  assert_eq(h_empty, 14695981039346656037UL)

  // "a" vector
  let h_a = fnv1a_64_str("a")
  assert_eq(h_a, 12638187200555641996UL)

  // Determinism check
  assert_eq(fnv1a_64_str("moonbit"), fnv1a_64_str("moonbit"))
  assert_true(fnv1a_64_str("moonbit") != fnv1a_64_str("MoonBit"))
}
