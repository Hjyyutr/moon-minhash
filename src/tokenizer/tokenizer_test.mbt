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

///|
test "porter stemmer" {
  let stemmer = PorterStemmer::new()
  assert_eq(stemmer.stem("connections"), "connect")
  assert_eq(stemmer.stem("connecting"), "connect")
  assert_eq(stemmer.stem("connected"), "connect")
  assert_eq(stemmer.stem("sses"), "ss")
  assert_eq(stemmer.stem("flies"), "fli")
}

///|
test "stop words filter" {
  assert_true(is_stop_word("and"))
  assert_true(is_stop_word("the"))
  assert_false(is_stop_word("moonbit"))

  let tokens = ["moonbit", "is", "a", "fast", "language"]
  let filtered = filter_stop_words(tokens)
  assert_eq(filtered, ["moonbit", "fast", "language"])
}

///|
test "porter stemmer vocabulary check" {
  let stemmer = PorterStemmer::new()
  let cases = [
    ("relate", "relat"),
    ("relating", "relat"),
    ("relational", "relat"),
    ("relativity", "relat"),
    ("adjustment", "adjust"),
    ("adjustable", "adjust"),
    ("agreeable", "agreeabl"),
    ("adoption", "adopt"),
    ("adopting", "adopt"),
    ("rational", "ration"),
    ("national", "nation"),
    ("activation", "activ"),
    ("activate", "activ"),
    ("digitizer", "digit"),
    ("digitize", "digit"),
    ("valency", "valenc"),
    ("hesitancy", "hesit"),
    ("formalism", "formal"),
    ("formalize", "formal"),
    ("goodness", "good"),
    ("hopeful", "hope"),
    ("hopeless", "hopeless"),
    ("defensiveness", "defens"),
    ("different", "differ"),
    ("difference", "differ"),
    ("reference", "refer"),
    ("referring", "refer"),
    ("allowance", "allow"),
    ("allowable", "allow"),
    ("probabilistic", "probabilist"),
    ("probability", "probabl"),
    ("vocalist", "vocal"),
    ("vocalize", "vocal"),
    ("traditional", "tradit"),
    ("tradition", "tradit"),
    ("playfulness", "play"),
    ("playful", "play"),
    ("sensation", "sensat"),
    ("sensational", "sensat"),
    ("sensitivity", "sensit"),
    ("sensitive", "sensit"),
    ("dependency", "depend"),
    ("dependent", "depend"),
    ("abatement", "abat"),
    ("abated", "abat"),
    ("abating", "abat"),
    ("replacement", "replac"),
    ("replaceable", "replac"),
    ("completion", "complet"),
    ("completed", "complet"),
    ("completing", "complet"),
  ]
  for i = 0; i < cases.length(); i = i + 1 {
    let (word, expected) = cases[i]
    assert_eq(stemmer.stem(word), expected)
  }
}

///|
test "cjk text check" {
  let text = "MoonBit 语言是非常快速和安全的！"
  let tokens = tokenize(text, CharNGram(2))
  assert_true(tokens.length() > 0)
}
