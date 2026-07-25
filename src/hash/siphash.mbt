// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// SipHash-2-4 implementation for robust keyed hashing.
pub fn siphash24(bytes : Bytes, k0 : UInt64, k1 : UInt64) -> UInt64 {
  let mut v0 : UInt64 = k0 ^ 0x736f6d6570736575UL
  let mut v1 : UInt64 = k1 ^ 0x646f72616d617465UL
  let mut v2 : UInt64 = k0 ^ 0x6c7967656e657261UL
  let mut v3 : UInt64 = k1 ^ 0x7465646279746573UL

  let len = bytes.length()
  let left = len % 8
  let nblocks = len / 8

  for i = 0; i < nblocks; i = i + 1 {
    let offset = i * 8
    let m = read_u64_le(bytes, offset)
    v3 = v3 ^ m

    // SipRound 1
    v0 = v0 + v1
    v1 = rotl64(v1, 13)
    v1 = v1 ^ v0
    v0 = rotl64(v0, 32)
    v2 = v2 + v3
    v3 = rotl64(v3, 16)
    v3 = v3 ^ v2
    v0 = v0 + v3
    v3 = rotl64(v3, 21)
    v3 = v3 ^ v0
    v2 = v2 + v1
    v1 = rotl64(v1, 17)
    v1 = v1 ^ v2
    v2 = rotl64(v2, 32)

    // SipRound 2
    v0 = v0 + v1
    v1 = rotl64(v1, 13)
    v1 = v1 ^ v0
    v0 = rotl64(v0, 32)
    v2 = v2 + v3
    v3 = rotl64(v3, 16)
    v3 = v3 ^ v2
    v0 = v0 + v3
    v3 = rotl64(v3, 21)
    v3 = v3 ^ v0
    v2 = v2 + v1
    v1 = rotl64(v1, 17)
    v1 = v1 ^ v2
    v2 = rotl64(v2, 32)

    v0 = v0 ^ m
  }

  let mut b = (len.to_uint64() & 0xffUL) << 56
  let tail_off = nblocks * 8
  if left >= 7 {
    b = b | (bytes[tail_off + 6].to_uint64() << 48)
  }
  if left >= 6 {
    b = b | (bytes[tail_off + 5].to_uint64() << 40)
  }
  if left >= 5 {
    b = b | (bytes[tail_off + 4].to_uint64() << 32)
  }
  if left >= 4 {
    b = b | (bytes[tail_off + 3].to_uint64() << 24)
  }
  if left >= 3 {
    b = b | (bytes[tail_off + 2].to_uint64() << 16)
  }
  if left >= 2 {
    b = b | (bytes[tail_off + 1].to_uint64() << 8)
  }
  if left >= 1 {
    b = b | bytes[tail_off].to_uint64()
  }

  v3 = v3 ^ b

  // SipRound 1
  v0 = v0 + v1
  v1 = rotl64(v1, 13)
  v1 = v1 ^ v0
  v0 = rotl64(v0, 32)
  v2 = v2 + v3
  v3 = rotl64(v3, 16)
  v3 = v3 ^ v2
  v0 = v0 + v3
  v3 = rotl64(v3, 21)
  v3 = v3 ^ v0
  v2 = v2 + v1
  v1 = rotl64(v1, 17)
  v1 = v1 ^ v2
  v2 = rotl64(v2, 32)

  // SipRound 2
  v0 = v0 + v1
  v1 = rotl64(v1, 13)
  v1 = v1 ^ v0
  v0 = rotl64(v0, 32)
  v2 = v2 + v3
  v3 = rotl64(v3, 16)
  v3 = v3 ^ v2
  v0 = v0 + v3
  v3 = rotl64(v3, 21)
  v3 = v3 ^ v0
  v2 = v2 + v1
  v1 = rotl64(v1, 17)
  v1 = v1 ^ v2
  v2 = rotl64(v2, 32)

  v0 = v0 ^ b
  v2 = v2 ^ 0xffUL

  // SipRound 4 finalization
  for r = 0; r < 4; r = r + 1 {
    v0 = v0 + v1
    v1 = rotl64(v1, 13)
    v1 = v1 ^ v0
    v0 = rotl64(v0, 32)
    v2 = v2 + v3
    v3 = rotl64(v3, 16)
    v3 = v3 ^ v2
    v0 = v0 + v3
    v3 = rotl64(v3, 21)
    v3 = v3 ^ v0
    v2 = v2 + v1
    v1 = rotl64(v1, 17)
    v1 = v1 ^ v2
    v2 = rotl64(v2, 32)
  }

  v0 ^ v1 ^ v2 ^ v3
}

///|
fn rotl64(val : UInt64, bits : Int) -> UInt64 {
  (val << bits) | (val >> (64 - bits))
}

///|
fn read_u64_le(bytes : Bytes, offset : Int) -> UInt64 {
  bytes[offset].to_uint64() |
  (bytes[offset + 1].to_uint64() << 8) |
  (bytes[offset + 2].to_uint64() << 16) |
  (bytes[offset + 3].to_uint64() << 24) |
  (bytes[offset + 4].to_uint64() << 32) |
  (bytes[offset + 5].to_uint64() << 40) |
  (bytes[offset + 6].to_uint64() << 48) |
  (bytes[offset + 7].to_uint64() << 56)
}
