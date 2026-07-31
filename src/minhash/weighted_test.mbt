// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
test "natural log ln mathematical verification" {
  let epsilon = 0.000000001
  // ln(1.0) = 0.0
  let ln_1 = ln(1.0)
  assert_true((ln_1 - 0.0).abs() < epsilon)

  // ln(2.718281828459) ~ 1.0
  let ln_e = ln(2.718281828459045)
  assert_true((ln_e - 1.0).abs() < epsilon)

  // ln(2.0) ~ 0.6931471805599
  let ln_2 = ln(2.0)
  assert_true((ln_2 - 0.6931471805599453).abs() < epsilon)

  // ln(0.5) ~ -0.6931471805599
  let ln_half = ln(0.5)
  assert_true((ln_half - -0.6931471805599453).abs() < epsilon)
}

///|
test "consistent weighted sampling statistical jaccard convergence" {
  let w1 = [
    WeightedElement::new(1U, 1.0),
    WeightedElement::new(2U, 2.0),
    WeightedElement::new(3U, 5.0),
    WeightedElement::new(4U, 0.0),
  ]
  let w2 = [
    WeightedElement::new(1U, 1.5),
    WeightedElement::new(2U, 1.5),
    WeightedElement::new(3U, 4.0),
    WeightedElement::new(4U, 0.5),
  ]

  // True Jaccard = sum(min(w1_i, w2_i)) / sum(max(w1_i, w2_i))
  // min = [1.0, 1.5, 4.0, 0.0] -> sum = 6.5
  // max = [1.5, 2.0, 5.0, 0.5] -> sum = 9.0
  // True Jaccard = 6.5 / 9.0 = 0.722222
  let true_jaccard = 6.5 / 9.0

  // Compute signatures with 128 hashes
  let sig1 = compute_weighted_minhash(w1, 128, 42U)
  let sig2 = compute_weighted_minhash(w2, 128, 42U)

  let estimated_jaccard = weighted_jaccard_similarity(sig1, sig2)
  assert_true((estimated_jaccard - true_jaccard).abs() < 0.25)
}
