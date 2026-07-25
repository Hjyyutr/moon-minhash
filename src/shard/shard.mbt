// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// ShardPartition structure for distributed & memory-mapped partition indexing.
pub struct ShardPartition {
  shard_id : Int
  b : Int
  r : Int
  mut num_docs : Int
  lsh_index : @lsh.LSHIndex
  doc_map : Map[String, Bool]
}

///|
pub fn ShardPartition::new(shard_id : Int, b : Int, r : Int) -> ShardPartition {
  {
    shard_id,
    b,
    r,
    num_docs: 0,
    lsh_index: @lsh.LSHIndex::new(b, r),
    doc_map: Map::from_array([]),
  }
}

///|
/// Inserts document into shard partition.
pub fn ShardPartition::insert(
  self : ShardPartition,
  doc_id : String,
  sig : @minhash.MinHashSignature,
) -> Unit {
  if !self.doc_map.contains(doc_id) {
    self.doc_map.set(doc_id, true)
    self.num_docs = self.num_docs + 1
    self.lsh_index.insert(doc_id, sig)
  }
}

///|
/// Queries candidates from shard partition.
pub fn ShardPartition::query_candidates(
  self : ShardPartition,
  query_sig : @minhash.MinHashSignature,
) -> Array[String] {
  self.lsh_index.query_candidates(query_sig)
}
