// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
test "s-curve probability" {
  let prob_high = s_curve_probability(0.8, 20, 5)
  let prob_low = s_curve_probability(0.2, 20, 5)
  assert_true(prob_high > 0.8)
  assert_true(prob_low < 0.1)
}

///|
test "auto-tune lsh params" {
  let config = auto_tune_lsh_params(100, 0.7)
  assert_eq(config.b * config.r, 100)
}

///|
test "lsh index search candidate recall" {
  let hasher = @minhash.MinHasher::new(64, 42UL)
  let index = LSHIndex::new(16, 4)

  let doc1 = "MoonBit fast programming language for modern WebAssembly"
  let doc2 = "MoonBit fast programming language for modern WebAssembly targets"
  let doc3 = "Python is a dynamic interpreted scripting language"

  let sig1 = hasher.compute_text(doc1)
  let sig2 = hasher.compute_text(doc2)
  let sig3 = hasher.compute_text(doc3)

  index.insert("doc1", sig1)
  index.insert("doc2", sig2)
  index.insert("doc3", sig3)

  let matches = index.query_similar(sig1, 0.5)
  assert_true(matches.length() >= 2)
}

///|
test "multi-probe candidate search" {
  let hasher = @minhash.MinHasher::new(32, 100UL)
  let index = LSHIndex::new(8, 4)
  let sig = hasher.compute_text("test multi probe query text")
  index.insert("d1", sig)

  let cands = query_candidates_multiprobe(index, sig, 2)
  assert_true(cands.length() >= 1)
}
