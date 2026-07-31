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

///|
test "benchmark similarity distance metrics throughput" {
  let s1 = "MoonBit is an extremely fast systems programming language designed for WebAssembly"
  let s2 = "MoonBit is an extremely fast systems language targeting WebAssembly runtimes"

  let mut sum = 0.0
  for i = 0; i < 100; i = i + 1 {
    sum = sum + @similarity.levenshtein_similarity(s1, s2)
    sum = sum + @similarity.jaro_winkler_similarity(s1, s2)
    sum = sum + @similarity.sorensen_dice_coefficient(s1, s2)
    sum = sum + @similarity.cosine_similarity(s1, s2)
    sum = sum + @similarity.overlap_coefficient(s1, s2)
    sum = sum + @similarity.tversky_index(s1, s2, 0.5, 0.5)
    sum = sum + @similarity.string_jaccard_similarity(s1, s2)
  }
  assert_true(sum > 0.0)
}

///|
test "benchmark simhash fingerprinting and lsh query" {
  let hasher = @lsh.SimHasher::new(64, 42U)
  let index = @lsh.SimHashLSH::new(64, 10, 8)
  let fp_map = Map::from_array([])

  for i = 0; i < 100; i = i + 1 {
    let tokens = [
      "moonbit",
      "language",
      "fast",
      "document",
      "dedup",
      "hash",
      "token_" + i.to_string(),
    ]
    let fp = hasher.compute_fingerprint(tokens)
    let doc_id = "doc_" + i.to_string()
    index.insert(doc_id, fp)
    fp_map.set(doc_id, fp)
  }

  let query_tokens = [
    "moonbit", "language", "fast", "document", "dedup", "hash", "token_50",
  ]
  let query_fp = hasher.compute_fingerprint(query_tokens)
  let cands = index.query(query_fp, fp_map)
  assert_true(cands.length() >= 1)
}

///|
test "benchmark fnv hash throughput" {
  let mut sum32 = 0U
  let mut sum64 = 0UL
  for i = 0; i < 1000; i = i + 1 {
    let s = "benchmark_payload_" + i.to_string()
    sum32 = sum32 ^ @hash.fnv1a_32_str(s)
    sum64 = sum64 ^ @hash.fnv1a_64_str(s)
  }
  assert_true(sum32 > 0U)
  assert_true(sum64 > 0UL)
}

///|
test "benchmark porter stemmer throughput" {
  let stemmer = @tokenizer.PorterStemmer::new()
  let words = [
    "connections", "connecting", "connected", "connection", "programming", "programmer",
    "programmed", "programs", "development", "developer", "developing", "developed",
    "performance", "performing", "performed", "performer", "documentation", "documenting",
    "documented", "documents",
  ]
  let mut total_len = 0
  for round = 0; round < 50; round = round + 1 {
    for i = 0; i < words.length(); i = i + 1 {
      let stemmed = stemmer.stem(words[i])
      total_len = total_len + stemmed.length()
    }
  }
  assert_true(total_len > 0)
}
