// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Locality-Sensitive Hashing (LSH) Index for fast candidate document similarity search.
pub struct LSHIndex {
  b : Int
  r : Int
  num_hashes : Int
  // Map of band_id -> (bucket_hash -> list of doc_ids)
  buckets : Map[Int, Map[UInt, Array[String]]]
  // Storage of original signatures for verification
  signatures : Map[String, @minhash.MinHashSignature]
}

///|
pub fn LSHIndex::new(b : Int, r : Int) -> LSHIndex {
  let buckets = Map::from_array([])
  for band = 0; band < b; band = band + 1 {
    buckets.set(band, Map::from_array([]))
  }
  { b, r, num_hashes: b * r, buckets, signatures: Map::from_array([]) }
}

///|
/// Hashes a slice of signature values for a specific band to a 32-bit uint bucket key.
fn hash_band(values : Array[UInt], band : Int, r : Int) -> UInt {
  let offset = band * r
  let sb = StringBuilder::new()
  sb.write_string(band.to_string())
  sb.write_char(':')
  for i = 0; i < r; i = i + 1 {
    if i > 0 {
      sb.write_char(',')
    }
    sb.write_string(values[offset + i].to_string())
  }
  @hash.murmurhash3_32_str(sb.to_string(), 42U)
}

///|
/// Inserts a document with ID and MinHash signature into the LSH index.
pub fn LSHIndex::insert(
  self : LSHIndex,
  doc_id : String,
  sig : @minhash.MinHashSignature,
) -> Unit {
  if sig.num_hashes != self.num_hashes {
    return
  }

  self.signatures.set(doc_id, sig)

  for band = 0; band < self.b; band = band + 1 {
    let bucket_hash = hash_band(sig.values, band, self.r)
    match self.buckets.get(band) {
      Some(band_map) =>
        match band_map.get(bucket_hash) {
          Some(arr) => arr.push(doc_id)
          None => band_map.set(bucket_hash, [doc_id])
        }
      None => ()
    }
  }
}

///|
/// Queries for candidate document IDs that share at least one band bucket with query signature.
pub fn LSHIndex::query_candidates(
  self : LSHIndex,
  query_sig : @minhash.MinHashSignature,
) -> Array[String] {
  if query_sig.num_hashes != self.num_hashes {
    return []
  }

  let candidates_map = Map::from_array([])
  for band = 0; band < self.b; band = band + 1 {
    let bucket_hash = hash_band(query_sig.values, band, self.r)
    match self.buckets.get(band) {
      Some(band_map) =>
        match band_map.get(bucket_hash) {
          Some(arr) =>
            for i = 0; i < arr.length(); i = i + 1 {
              candidates_map.set(arr[i], true)
            }
          None => ()
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

///|
/// Queries candidate documents and verifies exact Jaccard similarity >= threshold.
pub fn LSHIndex::query_similar(
  self : LSHIndex,
  query_sig : @minhash.MinHashSignature,
  threshold : Double,
) -> Array[(String, Double)] {
  let candidates = self.query_candidates(query_sig)
  let result = Array::new()

  for i = 0; i < candidates.length(); i = i + 1 {
    let cand_id = candidates[i]
    match self.signatures.get(cand_id) {
      Some(cand_sig) => {
        let sim = @minhash.jaccard_similarity(query_sig, cand_sig)
        if sim >= threshold {
          result.push((cand_id, sim))
        }
      }
      None => ()
    }
  }

  result
}
