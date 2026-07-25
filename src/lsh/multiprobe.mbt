// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Multi-probe LSH search extension.
/// Generates adjacent bucket hash probes to catch candidate documents near bucket boundaries.
pub fn generate_multi_probe_keys(
  base_hash : UInt,
  num_probes : Int,
) -> Array[UInt] {
  let probes = Array::new(capacity=num_probes + 1)
  probes.push(base_hash)

  let perturbs = [1U, 2U, 4U, 8U, 16U, 32U, 64U, 128U]
  let max_p = if num_probes < perturbs.length() {
    num_probes
  } else {
    perturbs.length()
  }

  for i = 0; i < max_p; i = i + 1 {
    probes.push(base_hash ^ perturbs[i])
  }

  probes
}

///|
/// Queries candidates using multi-probe bucketing for higher recall.
pub fn query_candidates_multiprobe(
  index : LSHIndex,
  query_sig : @minhash.MinHashSignature,
  probes_per_band : Int,
) -> Array[String] {
  if query_sig.num_hashes != index.num_hashes {
    return []
  }

  let candidates_map = Map::from_array([])
  for band = 0; band < index.b; band = band + 1 {
    let base_hash = hash_band(query_sig.values, band, index.r)
    let keys = generate_multi_probe_keys(base_hash, probes_per_band)

    match index.buckets.get(band) {
      Some(band_map) =>
        for k_idx = 0; k_idx < keys.length(); k_idx = k_idx + 1 {
          match band_map.get(keys[k_idx]) {
            Some(arr) =>
              for i = 0; i < arr.length(); i = i + 1 {
                candidates_map.set(arr[i], true)
              }
            None => ()
          }
        }
      None => ()
    }
  }

  let result = Array::new()
  for k, _v in candidates_map {
    result.push(k)
  }
  result
}
