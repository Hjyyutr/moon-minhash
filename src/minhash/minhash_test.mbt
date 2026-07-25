// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
test "minhash signature similarity for identical text" {
  let hasher = MinHasher::new(64, 42UL)
  let text = "MoonBit fast programming language for modern WebAssembly and native targets"
  let sig1 = hasher.compute_text(text)
  let sig2 = hasher.compute_text(text)

  let sim = jaccard_similarity(sig1, sig2)
  assert_eq(sim, 1.0)
}

///|
test "minhash signature similarity for similar text" {
  let hasher = MinHasher::new(128, 42UL)
  let doc1 = "MoonBit is a fast programming language designed for modern AI and WebAssembly infrastructure."
  let doc2 = "MoonBit is a fast programming language engineered for modern AI and WebAssembly cloud platforms."

  let sig1 = hasher.compute_text(doc1)
  let sig2 = hasher.compute_text(doc2)

  let sim = jaccard_similarity(sig1, sig2)
  assert_true(sim > 0.4)
}

///|
test "minhash signature merge" {
  let sig_a = MinHashSignature::from_values([10U, 50U, 30U])
  let sig_b = MinHashSignature::from_values([20U, 10U, 40U])
  let merged = merge_signatures(sig_a, sig_b)

  assert_eq(merged.values[0], 10U)
  assert_eq(merged.values[1], 10U)
  assert_eq(merged.values[2], 30U)
}

///|
test "super minhash computation" {
  let sm = SuperMinHasher::new(32, 100U)
  let tokens = [123U, 456U, 789U, 101112U]
  let sig = sm.compute(tokens)
  assert_eq(sig.num_hashes, 32)
}

///|
test "weighted minhash similarity" {
  let elems1 = [WeightedElement::new(1U, 2.0), WeightedElement::new(2U, 5.0)]
  let elems2 = [WeightedElement::new(1U, 2.0), WeightedElement::new(2U, 4.5)]
  let sig1 = compute_weighted_minhash(elems1, 32, 42U)
  let sig2 = compute_weighted_minhash(elems2, 32, 42U)
  let sim = weighted_jaccard_similarity(sig1, sig2)
  assert_true(sim > 0.5)
}
