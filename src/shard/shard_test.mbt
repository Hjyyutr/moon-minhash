// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
test "shard partition insert and query" {
  let hasher = @minhash.MinHasher::new(32, 42UL)
  let shard = ShardPartition::new(0, 8, 4)

  let sig1 = hasher.compute_text("moonbit partition shard indexing")
  let sig2 = hasher.compute_text("moonbit partition shard querying")

  shard.insert("doc1", sig1)
  shard.insert("doc2", sig2)

  assert_eq(shard.num_docs, 2)
  let cands = shard.query_candidates(sig1)
  assert_true(cands.length() >= 1)
}

///|
test "shard manager routing and candidate query" {
  let hasher = @minhash.MinHasher::new(32, 100UL)
  let manager = ShardManager::new(8, 4, 4)

  let sig1 = hasher.compute_text("text document for manager testing 1")
  let sig2 = hasher.compute_text("text document for manager testing 2")

  manager.insert("doc1", sig1)
  manager.insert("doc2", sig2)

  let cands = manager.query_candidates_all(sig1)
  assert_true(cands.length() >= 1)
}

///|
test "merge shards" {
  let hasher = @minhash.MinHasher::new(32, 42UL)
  let s1 = ShardPartition::new(1, 8, 4)
  let s2 = ShardPartition::new(2, 8, 4)

  s1.insert("d1", hasher.compute_text("document one content"))
  s2.insert("d2", hasher.compute_text("document two content"))

  let merged = merge_shards(s1, s2, 99)
  assert_eq(merged.num_docs, 2)
  assert_true(merged.doc_map.contains("d1"))
  assert_true(merged.doc_map.contains("d2"))
}
