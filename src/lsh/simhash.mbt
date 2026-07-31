// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// SimHasher calculates SimHash (Charikar's LSH) fingerprints for Cosine Similarity.
pub struct SimHasher {
  fingerprint_size : Int
  seed : UInt
}

///|
pub fn SimHasher::new(fingerprint_size : Int, seed : UInt) -> SimHasher {
  let size = if fingerprint_size <= 0 {
    64
  } else if fingerprint_size > 64 {
    64
  } else {
    fingerprint_size
  }
  { fingerprint_size: size, seed }
}

///|
/// Computes 64-bit SimHash fingerprint for an array of string tokens.
pub fn SimHasher::compute_fingerprint(
  self : SimHasher,
  tokens : Array[String],
) -> UInt64 {
  let v = Array::make(self.fingerprint_size, 0.0)

  for idx = 0; idx < tokens.length(); idx = idx + 1 {
    let token = tokens[idx]

    // Hash token using MurmurHash3 to get a 32-bit hash, and SipHash to get a 64-bit hash
    let token_bytes = @utf8.encode(token)
    let hash_val = @hash.siphash24(
      token_bytes,
      self.seed.to_uint64(),
      0x9e3779b9UL,
    )

    for i = 0; i < self.fingerprint_size; i = i + 1 {
      let bit_set = ((hash_val >> i) & 1UL) == 1UL
      if bit_set {
        v[i] = v[i] + 1.0
      } else {
        v[i] = v[i] - 1.0
      }
    }
  }

  let mut fingerprint = 0UL
  for i = 0; i < self.fingerprint_size; i = i + 1 {
    if v[i] > 0.0 {
      fingerprint = fingerprint | (1UL << i)
    }
  }

  fingerprint
}

///|
/// Computes Hamming distance between two 64-bit fingerprints.
pub fn hamming_distance(f1 : UInt64, f2 : UInt64) -> Int {
  let mut x = f1 ^ f2
  let mut dist = 0
  while x > 0UL {
    if (x & 1UL) == 1UL {
      dist = dist + 1
    }
    x = x >> 1
  }
  dist
}

///|
/// Computes Cosine Similarity estimate from two SimHash fingerprints.
/// similarity = cos( (HammingDistance / size) * pi )
pub fn simhash_cosine_similarity(
  f1 : UInt64,
  f2 : UInt64,
  size : Int,
) -> Double {
  let dist = hamming_distance(f1, f2)
  let dist_ratio = dist.to_double() / size.to_double()
  // Cosine of angle theta = dist_ratio * pi
  // Approximation of cos(x) where x in [0, pi]
  // cos(x) ~ 1 - 2*x/pi when x close to 0, or exact cos approximation:
  // Jaccard Cosine similarity is usually estimated simply as the fraction of matching bits:
  1.0 - dist_ratio
}

///|
/// SimHashLSH index supporting fast Hamming distance queries.
pub struct SimHashLSH {
  size : Int
  threshold : Int
  // Map of bucketing (split 64-bit fingerprint into multiple bands to query matches)
  bands : Array[Map[UInt, Array[String]]]
  num_bands : Int
  mask : UInt
}

///|
pub fn SimHashLSH::new(
  size : Int,
  threshold : Int,
  num_bands : Int,
) -> SimHashLSH {
  let bands = Array::new(capacity=num_bands)
  for i = 0; i < num_bands; i = i + 1 {
    bands.push(Map::from_array([]))
  }
  let bits_per_band = 64 / num_bands
  let mask = ((1UL << bits_per_band) - 1UL).to_uint()
  { size, threshold, bands, num_bands, mask }
}

///|
fn SimHashLSH::get_band_key(
  self : SimHashLSH,
  fingerprint : UInt64,
  band_idx : Int,
) -> UInt {
  let bits_per_band = 64 / self.num_bands
  let shift = band_idx * bits_per_band
  (fingerprint >> shift).to_uint() & self.mask
}

///|
/// Inserts a document fingerprint into the SimHashLSH index.
pub fn SimHashLSH::insert(
  self : SimHashLSH,
  doc_id : String,
  fingerprint : UInt64,
) -> Unit {
  for i = 0; i < self.num_bands; i = i + 1 {
    let key = self.get_band_key(fingerprint, i)
    let map = self.bands[i]
    match map.get(key) {
      Some(arr) => arr.push(doc_id)
      None => map.set(key, [doc_id])
    }
  }
}

///|
/// Queries the index for document IDs within the Hamming distance threshold.
pub fn SimHashLSH::query(
  self : SimHashLSH,
  fingerprint : UInt64,
  fingerprints_map : Map[String, UInt64],
) -> Array[String] {
  let candidates = Map::from_array([])

  for i = 0; i < self.num_bands; i = i + 1 {
    let key = self.get_band_key(fingerprint, i)
    let map = self.bands[i]
    match map.get(key) {
      Some(arr) =>
        for j = 0; j < arr.length(); j = j + 1 {
          let cand = arr[j]
          candidates.set(cand, true)
        }
      None => ()
    }
  }

  let results = Array::new()
  for cand, _ in candidates {
    match fingerprints_map.get(cand) {
      Some(cand_f) => {
        let dist = hamming_distance(fingerprint, cand_f)
        if dist <= self.threshold {
          results.push(cand)
        }
      }
      None => ()
    }
  }

  results
}
