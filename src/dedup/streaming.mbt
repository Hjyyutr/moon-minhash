// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Real-time streaming document deduplicator.
pub struct DedupResult {
  is_duplicate : Bool
  matched_doc_id : String
  similarity : Double
}

///|
pub struct StreamingDeduplicator {
  threshold : Double
  minhasher : @minhash.MinHasher
  lsh_index : @lsh.LSHIndex
}

///|
pub fn StreamingDeduplicator::new(
  threshold : Double,
  num_hashes : Int,
  seed : UInt64,
) -> StreamingDeduplicator {
  let params = @lsh.auto_tune_lsh_params(num_hashes, threshold)
  let minhasher = @minhash.MinHasher::new(num_hashes, seed)
  let lsh_index = @lsh.LSHIndex::new(params.b, params.r)
  { threshold, minhasher, lsh_index }
}

///|
/// Processes an incoming streaming document.
/// Returns DedupResult indicating whether it is a duplicate of a previously seen document.
pub fn StreamingDeduplicator::process(
  self : StreamingDeduplicator,
  doc_id : String,
  text : String,
) -> DedupResult {
  let sig = self.minhasher.compute_text(text)
  let matches = self.lsh_index.query_similar(sig, self.threshold)

  if matches.length() > 0 {
    let top_match = matches[0]
    self.lsh_index.insert(doc_id, sig)
    { is_duplicate: true, matched_doc_id: top_match.0, similarity: top_match.1 }
  } else {
    self.lsh_index.insert(doc_id, sig)
    { is_duplicate: false, matched_doc_id: "", similarity: 0.0 }
  }
}
