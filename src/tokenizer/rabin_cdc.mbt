// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Content-Defined Chunking (CDC) using Rabin Fingerprinting.
/// Divides long documents into variable-length chunks based on content boundaries.
pub struct RabinCDCConfig {
  min_chunk_size : Int
  max_chunk_size : Int
  target_chunk_size : Int
  window_size : Int
}

///|
pub fn RabinCDCConfig::default() -> RabinCDCConfig {
  {
    min_chunk_size: 64,
    max_chunk_size: 4096,
    target_chunk_size: 512,
    window_size: 48,
  }
}

///|
pub fn chunk_text_rabin(
  text : String,
  config : RabinCDCConfig,
) -> Array[String] {
  let len = text.length()
  if len <= config.min_chunk_size {
    if len > 0 {
      return [text]
    } else {
      return []
    }
  }

  let result = Array::new()
  let mask = (config.target_chunk_size - 1).reinterpret_as_uint()
  let mut chunk_start = 0
  let mut fingerprint : UInt = 0U
  let mut i = 0

  for ch in text {
    let current_chunk_len = i - chunk_start + 1
    let code = ch.to_int().reinterpret_as_uint()
    fingerprint = ((fingerprint << 1) | (fingerprint >> 31)) ^ code

    let is_boundary = (fingerprint & mask) == 0U &&
      current_chunk_len >= config.min_chunk_size
    let force_boundary = current_chunk_len >= config.max_chunk_size

    if is_boundary || force_boundary {
      result.push(text[chunk_start:i + 1].to_owned())
      chunk_start = i + 1
      fingerprint = 0U
    }
    i = i + 1
  }

  if chunk_start < len {
    result.push(text[chunk_start:len].to_owned())
  }

  result
}
