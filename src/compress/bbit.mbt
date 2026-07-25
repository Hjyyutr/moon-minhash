// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// b-bit MinHash quantization (1-bit, 2-bit, 4-bit) for high-density space-efficient signature storage.
pub(all) enum BBitMode {
  OneBit
  TwoBit
  FourBit
}

///|
pub struct BBitMinHashSignature {
  b_bits : Int
  num_hashes : Int
  packed_data : FixedArray[Byte]
}

///|
/// Quantizes a full 32-bit MinHash signature into a compact b-bit signature representation.
pub fn quantize_minhash(
  sig : @minhash.MinHashSignature,
  mode : BBitMode,
) -> BBitMinHashSignature {
  let num_hashes = sig.num_hashes
  let b_bits = match mode {
    OneBit => 1
    TwoBit => 2
    FourBit => 4
  }

  let mask = match mode {
    OneBit => 0x1U
    TwoBit => 0x3U
    FourBit => 0xfU
  }

  let total_bits = num_hashes * b_bits
  let num_bytes = (total_bits + 7) / 8
  let buf = FixedArray::make(num_bytes, (0).to_byte())

  let mut bit_offset = 0
  for i = 0; i < num_hashes; i = i + 1 {
    let val = sig.values[i] & mask
    let byte_idx = bit_offset / 8
    let in_byte_shift = bit_offset % 8

    let current = buf[byte_idx].to_int()
    let updated = current | (val.reinterpret_as_int() << in_byte_shift)
    buf[byte_idx] = updated.to_byte()

    if in_byte_shift + b_bits > 8 {
      let overflow_bits = in_byte_shift + b_bits - 8
      let next_val = val.reinterpret_as_int() >> (b_bits - overflow_bits)
      let next_current = buf[byte_idx + 1].to_int()
      buf[byte_idx + 1] = (next_current | next_val).to_byte()
    }

    bit_offset = bit_offset + b_bits
  }

  { b_bits, num_hashes, packed_data: buf }
}

///|
/// Extracts the b-bit value at index i from compressed signature.
pub fn BBitMinHashSignature::get_val(
  self : BBitMinHashSignature,
  i : Int,
) -> UInt {
  if i < 0 || i >= self.num_hashes {
    return 0U
  }

  let bit_offset = i * self.b_bits
  let byte_idx = bit_offset / 8
  let in_byte_shift = bit_offset % 8

  let mask = match self.b_bits {
    1 => 0x1U
    2 => 0x3U
    4 => 0xfU
    _ => 0xfU
  }

  let b0 = self.packed_data[byte_idx].to_int().reinterpret_as_uint()
  let mut val = (b0 >> in_byte_shift) & mask

  if in_byte_shift + self.b_bits > 8 && byte_idx + 1 < self.packed_data.length() {
    let b1 = self.packed_data[byte_idx + 1].to_int().reinterpret_as_uint()
    let needed = in_byte_shift + self.b_bits - 8
    let top = (b1 & ((1U << needed) - 1U)) << (self.b_bits - needed)
    val = val | top
  }

  val
}

///|
/// Estimates Jaccard similarity between two b-bit quantized MinHash signatures.
pub fn bbit_jaccard_similarity(
  sig_a : BBitMinHashSignature,
  sig_b : BBitMinHashSignature,
) -> Double {
  if sig_a.num_hashes != sig_b.num_hashes || sig_a.b_bits != sig_b.b_bits {
    return 0.0
  }

  let n = sig_a.num_hashes
  let mut matches = 0
  for i = 0; i < n; i = i + 1 {
    if sig_a.get_val(i) == sig_b.get_val(i) {
      matches = matches + 1
    }
  }

  let match_ratio = matches.to_double() / n.to_double()
  let p_c = 1.0 / (1U << sig_a.b_bits).to_double()

  let estimated_sim = (match_ratio - p_c) / (1.0 - p_c)
  if estimated_sim < 0.0 {
    0.0
  } else if estimated_sim > 1.0 {
    1.0
  } else {
    estimated_sim
  }
}
