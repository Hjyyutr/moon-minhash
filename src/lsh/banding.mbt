// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Banding configuration parameters for Locality Sensitive Hashing.
/// Total hash count k = b * r, where b is number of bands, r is rows per band.
pub struct LSHBandingConfig {
  b : Int
  r : Int
}

///|
pub fn LSHBandingConfig::new(b : Int, r : Int) -> LSHBandingConfig {
  { b, r }
}

///|
/// Computes S-curve probability of 2 documents with similarity s sharing at least one band.
/// P(s) = 1 - (1 - s^r)^b
pub fn s_curve_probability(s : Double, b : Int, r : Int) -> Double {
  if s <= 0.0 {
    return 0.0
  }
  if s >= 1.0 {
    return 1.0
  }

  // Calculate s^r
  let mut s_r = 1.0
  for i = 0; i < r; i = i + 1 {
    s_r = s_r * s
  }

  let one_minus_sr = 1.0 - s_r

  // Calculate (1 - s^r)^b
  let mut fail_prob = 1.0
  for i = 0; i < b; i = i + 1 {
    fail_prob = fail_prob * one_minus_sr
  }

  1.0 - fail_prob
}

///|
/// Auto-tunes optimal (b, r) parameters for a given similarity threshold target_s and signature size num_hashes.
pub fn auto_tune_lsh_params(
  num_hashes : Int,
  target_s : Double,
) -> LSHBandingConfig {
  let mut best_b = 1
  let mut best_r = num_hashes
  let mut min_diff = 1.0e9

  for b = 1; b <= num_hashes; b = b + 1 {
    if num_hashes % b == 0 {
      let r = num_hashes / b
      // s_threshold ~ (1/b)^(1/r)
      let prob = s_curve_probability(target_s, b, r)
      let diff = (prob - 0.5).abs()
      if diff < min_diff {
        min_diff = diff
        best_b = b
        best_r = r
      }
    }
  }

  { b: best_b, r: best_r }
}
