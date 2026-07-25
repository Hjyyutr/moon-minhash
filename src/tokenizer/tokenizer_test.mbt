// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
test "text normalization" {
  let raw = " Hello,  World!  MoonBit 2026. "
  let cfg = NormalizerConfig::default()
  let norm = normalize_text(raw, cfg)
  assert_eq(norm, "hello, world! moonbit 2026.")
}

///|
test "char ngrams" {
  let text = "moonbit"
  let ngrams = char_ngrams(text, 3)
  assert_eq(ngrams, ["moo", "oon", "onb", "nbi", "bit"])
}

///|
test "word ngrams" {
  let text = "moonbit language is fast and safe"
  let ngrams = word_ngrams(text, 2)
  assert_eq(ngrams[0], "moonbit language")
  assert_eq(ngrams[1], "language is")
}

///|
test "shingle builder" {
  let sb = ShingleBuilder::new(3, 42U)
  let shingles = sb.build_hashed_shingles("moonbit lsh deduplication engine")
  assert_true(shingles.length() > 0)
}

///|
test "rabin cdc chunking" {
  let text = "This is a long document designed to test rabin content defined chunking algorithm in moonbit tokenizer module."
  let cfg = RabinCDCConfig::default()
  let chunks = chunk_text_rabin(text, cfg)
  assert_true(chunks.length() >= 1)
}
