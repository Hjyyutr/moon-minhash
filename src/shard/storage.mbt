// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// ShardManager for multi-partition LSH indexing, routing, and shard merging.
pub struct ShardManager {
  b : Int
  r : Int
  shards : Array[ShardPartition]
}

///|
pub fn ShardManager::new(b : Int, r : Int, num_shards : Int) -> ShardManager {
  let shards = Array::new(capacity=num_shards)
  let n = if num_shards < 1 { 1 } else { num_shards }
  for i = 0; i < n; i = i + 1 {
    shards.push(ShardPartition::new(i, b, r))
  }
  { b, r, shards }
}

///|
/// Routes and inserts document into appropriate shard partition based on document ID hash.
pub fn ShardManager::insert(
  self : ShardManager,
  doc_id : String,
  sig : @minhash.MinHashSignature,
) -> Unit {
  let hash_val = @hash.murmurhash3_32_str(doc_id, 42U)
  let shard_idx = (hash_val % self.shards.length().reinterpret_as_uint()).reinterpret_as_int()
  self.shards[shard_idx].insert(doc_id, sig)
}

///|
/// Queries candidates across all managed shards.
pub fn ShardManager::query_candidates_all(
  self : ShardManager,
  query_sig : @minhash.MinHashSignature,
) -> Array[String] {
  let candidates_map = Map::from_array([])
  for i = 0; i < self.shards.length(); i = i + 1 {
    let shard_cands = self.shards[i].query_candidates(query_sig)
    for j = 0; j < shard_cands.length(); j = j + 1 {
      candidates_map.set(shard_cands[j], true)
    }
  }

  let result = Array::new()
  for k, _v in candidates_map {
    result.push(k)
  }
  result
}

///|
/// Merges two shard partitions into a single combined shard partition.
pub fn merge_shards(
  shard_a : ShardPartition,
  shard_b : ShardPartition,
  new_shard_id : Int,
) -> ShardPartition {
  let merged = ShardPartition::new(new_shard_id, shard_a.b, shard_a.r)

  // Insert all entries from shard_a
  for doc_id, _ in shard_a.doc_map {
    match shard_a.lsh_index.signatures.get(doc_id) {
      Some(sig) => merged.insert(doc_id, sig)
      None => ()
    }
  }

  // Insert all entries from shard_b
  for doc_id, _ in shard_b.doc_map {
    match shard_b.lsh_index.signatures.get(doc_id) {
      Some(sig) => merged.insert(doc_id, sig)
      None => ()
    }
  }

  merged
}
