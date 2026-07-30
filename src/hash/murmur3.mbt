// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// MurmurHash3 32-bit non-cryptographic hash function.
/// Provides fast execution, good distribution, and low collision rates.
pub fn murmurhash3_32(bytes : Bytes, seed : UInt) -> UInt {
  let c1 : UInt = 0xcc9e2d51U
  let c2 : UInt = 0x1b873593U
  let len = bytes.length()
  let mut h1 = seed
  let nblocks = len / 4

  // Body: Process 4-byte blocks
  for i = 0; i < nblocks; i = i + 1 {
    let offset = i * 4
    let mut k1 : UInt = bytes[offset].to_uint() |
      (bytes[offset + 1].to_uint() << 8) |
      (bytes[offset + 2].to_uint() << 16) |
      (bytes[offset + 3].to_uint() << 24)

    k1 = k1 * c1
    k1 = (k1 << 15) | (k1 >> 17) // rotl32(k1, 15)
    k1 = k1 * c2

    h1 = h1 ^ k1
    h1 = (h1 << 13) | (h1 >> 19) // rotl32(h1, 13)
    h1 = h1 * 5U + 0xe6546b64U
  }

  // Tail: Process remaining 1-3 bytes
  let tail_offset = nblocks * 4
  let rem = len % 4
  let mut k1_tail : UInt = 0U
  if rem == 3 {
    k1_tail = k1_tail ^ (bytes[tail_offset + 2].to_uint() << 16)
  }
  if rem >= 2 {
    k1_tail = k1_tail ^ (bytes[tail_offset + 1].to_uint() << 8)
  }
  if rem >= 1 {
    k1_tail = k1_tail ^ bytes[tail_offset].to_uint()
    k1_tail = k1_tail * c1
    k1_tail = (k1_tail << 15) | (k1_tail >> 17)
    k1_tail = k1_tail * c2
    h1 = h1 ^ k1_tail
  }

  // Finalization mix (avalanche)
  h1 = h1 ^ len.reinterpret_as_uint()
  h1 = h1 ^ (h1 >> 16)
  h1 = h1 * 0x85ebca6bU
  h1 = h1 ^ (h1 >> 13)
  h1 = h1 * 0xc2b2ae35U
  h1 = h1 ^ (h1 >> 16)
  h1
}

///|
/// MurmurHash3 32-bit helper for strings.
pub fn murmurhash3_32_str(str : String, seed : UInt) -> UInt {
  murmurhash3_32(@utf8.encode(str), seed)
}

///|
/// MurmurHash3 128-bit hash represented as a tuple of 4 32-bit unsigned integers.
pub fn murmurhash3_128(bytes : Bytes, seed : UInt) -> (UInt, UInt, UInt, UInt) {
  let c1 : UInt = 0x239b961bU
  let c2 : UInt = 0xab0e9789U
  let c3 : UInt = 0x38b34ae5U
  let c4 : UInt = 0xa1e38b93U

  let len = bytes.length()
  let mut h1 = seed
  let mut h2 = seed
  let mut h3 = seed
  let mut h4 = seed

  let nblocks = len / 16
  for i = 0; i < nblocks; i = i + 1 {
    let o = i * 16
    let mut k1 = bytes[o].to_uint() |
      (bytes[o + 1].to_uint() << 8) |
      (bytes[o + 2].to_uint() << 16) |
      (bytes[o + 3].to_uint() << 24)
    let mut k2 = bytes[o + 4].to_uint() |
      (bytes[o + 5].to_uint() << 8) |
      (bytes[o + 6].to_uint() << 16) |
      (bytes[o + 7].to_uint() << 24)
    let mut k3 = bytes[o + 8].to_uint() |
      (bytes[o + 9].to_uint() << 8) |
      (bytes[o + 10].to_uint() << 16) |
      (bytes[o + 11].to_uint() << 16)
    let mut k4 = bytes[o + 12].to_uint() |
      (bytes[o + 13].to_uint() << 8) |
      (bytes[o + 14].to_uint() << 16) |
      (bytes[o + 15].to_uint() << 24)

    k1 = k1 * c1
    k1 = (k1 << 15) | (k1 >> 17)
    k1 = k1 * c2
    h1 = h1 ^ k1
    h1 = (h1 << 19) | (h1 >> 13)
    h1 = h1 + h2
    h1 = h1 * 5U + 0x561d464dU

    k2 = k2 * c2
    k2 = (k2 << 16) | (k2 >> 16)
    k2 = k2 * c3
    h2 = h2 ^ k2
    h2 = (h2 << 17) | (h2 >> 15)
    h2 = h2 + h3
    h2 = h2 * 5U + 0x0bcaa747U

    k3 = k3 * c3
    k3 = (k3 << 17) | (k3 >> 15)
    k3 = k3 * c4
    h3 = h3 ^ k3
    h3 = (h3 << 15) | (h3 >> 17)
    h3 = h3 + h4
    h3 = h3 * 5U + 0x96cd1c35U

    k4 = k4 * c4
    k4 = (k4 << 18) | (k4 >> 14)
    k4 = k4 * c1
    h4 = h4 ^ k4
    h4 = (h4 << 13) | (h4 >> 19)
    h4 = h4 + h1
    h4 = h4 * 5U + 0x32ac3b17U
  }

  // Tail handling for 128-bit
  let tail_off = nblocks * 16
  let rem = len % 16
  let mut k1 : UInt = 0U
  let mut k2 : UInt = 0U
  let mut k3 : UInt = 0U
  let mut k4 : UInt = 0U

  if rem >= 15 {
    k4 = k4 ^ (bytes[tail_off + 14].to_uint() << 16)
  }
  if rem >= 14 {
    k4 = k4 ^ (bytes[tail_off + 13].to_uint() << 8)
  }
  if rem >= 13 {
    k4 = k4 ^ bytes[tail_off + 12].to_uint()
    k4 = k4 * c4
    k4 = (k4 << 18) | (k4 >> 14)
    k4 = k4 * c1
    h4 = h4 ^ k4
  }
  if rem >= 12 {
    k3 = k3 ^ (bytes[tail_off + 11].to_uint() << 24)
  }
  if rem >= 11 {
    k3 = k3 ^ (bytes[tail_off + 10].to_uint() << 16)
  }
  if rem >= 10 {
    k3 = k3 ^ (bytes[tail_off + 9].to_uint() << 8)
  }
  if rem >= 9 {
    k3 = k3 ^ bytes[tail_off + 8].to_uint()
    k3 = k3 * c3
    k3 = (k3 << 17) | (k3 >> 15)
    k3 = k3 * c4
    h3 = h3 ^ k3
  }
  if rem >= 8 {
    k2 = k2 ^ (bytes[tail_off + 7].to_uint() << 24)
  }
  if rem >= 7 {
    k2 = k2 ^ (bytes[tail_off + 6].to_uint() << 16)
  }
  if rem >= 6 {
    k2 = k2 ^ (bytes[tail_off + 5].to_uint() << 8)
  }
  if rem >= 5 {
    k2 = k2 ^ bytes[tail_off + 4].to_uint()
    k2 = k2 * c2
    k2 = (k2 << 16) | (k2 >> 16)
    k2 = k2 * c3
    h2 = h2 ^ k2
  }
  if rem >= 4 {
    k1 = k1 ^ (bytes[tail_off + 3].to_uint() << 24)
  }
  if rem >= 3 {
    k1 = k1 ^ (bytes[tail_off + 2].to_uint() << 16)
  }
  if rem >= 2 {
    k1 = k1 ^ (bytes[tail_off + 1].to_uint() << 8)
  }
  if rem >= 1 {
    k1 = k1 ^ bytes[tail_off].to_uint()
    k1 = k1 * c1
    k1 = (k1 << 15) | (k1 >> 17)
    k1 = k1 * c2
    h1 = h1 ^ k1
  }

  let ulen = len.reinterpret_as_uint()
  h1 = h1 ^ ulen
  h2 = h2 ^ ulen
  h3 = h3 ^ ulen
  h4 = h4 ^ ulen

  h1 = h1 + h2 + h3 + h4
  h2 = h2 + h1
  h3 = h3 + h1
  h4 = h4 + h1

  h1 = fmix32(h1)
  h2 = fmix32(h2)
  h3 = fmix32(h3)
  h4 = fmix32(h4)

  h1 = h1 + h2 + h3 + h4
  h2 = h2 + h1
  h3 = h3 + h1
  h4 = h4 + h1

  (h1, h2, h3, h4)
}

///|
fn fmix32(h_in : UInt) -> UInt {
  let mut h = h_in
  h = h ^ (h >> 16)
  h = h * 0x85ebca6bU
  h = h ^ (h >> 13)
  h = h * 0xc2b2ae35U
  h = h ^ (h >> 16)
  h
}
