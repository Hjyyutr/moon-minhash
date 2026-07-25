// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
test "benchmark hashing throughput" {
  let sample = "MoonBit fast non-cryptographic hashing algorithm evaluation payload"
  let mut total : UInt = 0U
  for i = 0; i < 5000; i = i + 1 {
    let h1 = @hash.murmurhash3_32_str(sample, i.reinterpret_as_uint())
    let h2 = @hash.xxhash32_str(sample, i.reinterpret_as_uint())
    total = total ^ h1 ^ h2
  }
  assert_true(total >= 0U)
}

///|
test "benchmark minhash signature calculation" {
  let hasher = @minhash.MinHasher::new(128, 42UL)
  let text = "High-performance MinHash signature generation benchmark for large-scale document deduplication in MoonBit language."
  let mut sig_len_accum = 0
  for i = 0; i < 100; i = i + 1 {
    let sig = hasher.compute_text(text)
    sig_len_accum = sig_len_accum + sig.num_hashes
  }
  assert_eq(sig_len_accum, 100 * 128)
}

///|
test "benchmark lsh candidate search scalability" {
  let hasher = @minhash.MinHasher::new(64, 42UL)
  let index = @lsh.LSHIndex::new(16, 4)

  for i = 0; i < 200; i = i + 1 {
    let doc = "Document payload #" +
      i.to_string() +
      " containing text data for LSH index scalability evaluation."
    let sig = hasher.compute_text(doc)
    index.insert("doc_" + i.to_string(), sig)
  }

  let query_sig = hasher.compute_text(
    "Document payload #50 containing text data for LSH index scalability evaluation.",
  )
  let cands = index.query_similar(query_sig, 0.7)
  assert_true(cands.length() >= 1)
}

///|
test "benchmark streaming deduplication speed" {
  let streamer = @dedup.StreamingDeduplicator::new(0.6, 64, 100UL)
  let mut dup_count = 0

  for i = 0; i < 150; i = i + 1 {
    let text = if i % 2 == 0 {
      "Near duplicate content item alpha for streaming throughput test."
    } else {
      "Unique item #" + i.to_string() + " with distinct keywords."
    }
    let res = streamer.process("item_" + i.to_string(), text)
    if res.is_duplicate {
      dup_count = dup_count + 1
    }
  }

  assert_true(dup_count > 50)
}
