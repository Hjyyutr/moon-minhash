// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// xxHash32 implementation in pure MoonBit.
/// Extremely fast non-cryptographic hash algorithm.
let prime32_1 : UInt = 2654435761U

///|
let prime32_2 : UInt = 2246822519U

///|
let prime32_3 : UInt = 3266489917U

///|
let prime32_4 : UInt = 668265263U

///|
let prime32_5 : UInt = 374761393U

///|
pub fn xxhash32(bytes : Bytes, seed : UInt) -> UInt {
  let len = bytes.length()
  let mut h32 : UInt = 0U

  if len >= 16 {
    let limit = len - 16
    let mut v1 = seed + prime32_1 + prime32_2
    let mut v2 = seed + prime32_2
    let mut v3 = seed + 0U
    let mut v4 = seed - prime32_1

    let mut p = 0
    while p <= limit {
      let read1 = read_u32_le(bytes, p)
      v1 = round32(v1, read1)
      p = p + 4

      let read2 = read_u32_le(bytes, p)
      v2 = round32(v2, read2)
      p = p + 4

      let read3 = read_u32_le(bytes, p)
      v3 = round32(v3, read3)
      p = p + 4

      let read4 = read_u32_le(bytes, p)
      v4 = round32(v4, read4)
      p = p + 4
    }

    h32 = rotl32(v1, 1) + rotl32(v2, 7) + rotl32(v3, 12) + rotl32(v4, 18)
  } else {
    h32 = seed + prime32_5
  }

  h32 = h32 + len.reinterpret_as_uint()

  let mut p = if len >= 16 { len - len % 16 } else { 0 }
  while p + 4 <= len {
    let read = read_u32_le(bytes, p)
    h32 = h32 + read * prime32_3
    h32 = rotl32(h32, 17) * prime32_4
    p = p + 4
  }

  while p < len {
    h32 = h32 + bytes[p].to_uint() * prime32_5
    h32 = rotl32(h32, 11) * prime32_1
    p = p + 1
  }

  h32 = h32 ^ (h32 >> 15)
  h32 = h32 * prime32_2
  h32 = h32 ^ (h32 >> 13)
  h32 = h32 * prime32_3
  h32 = h32 ^ (h32 >> 16)
  h32
}

///|
pub fn xxhash32_str(str : String, seed : UInt) -> UInt {
  xxhash32(@utf8.encode(str), seed)
}

///|
fn round32(acc : UInt, input : UInt) -> UInt {
  let mut a = acc + input * prime32_2
  a = rotl32(a, 13)
  a = a * prime32_1
  a
}

///|
fn rotl32(val : UInt, bits : Int) -> UInt {
  (val << bits) | (val >> (32 - bits))
}

///|
fn read_u32_le(bytes : Bytes, offset : Int) -> UInt {
  bytes[offset].to_uint() |
  (bytes[offset + 1].to_uint() << 8) |
  (bytes[offset + 2].to_uint() << 16) |
  (bytes[offset + 3].to_uint() << 24)
}
