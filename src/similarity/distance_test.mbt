// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
test "levenshtein distance" {
  assert_eq(levenshtein_distance("kitten", "sitting"), 3)
  assert_eq(levenshtein_distance("flaw", "lawn"), 2)
  assert_eq(levenshtein_distance("moonbit", "moonbit"), 0)
  assert_eq(levenshtein_distance("", "abc"), 3)
}

///|
test "levenshtein similarity" {
  let sim = levenshtein_similarity("kitten", "sitting")
  assert_true(sim > 0.5)
}

///|
test "damerau levenshtein distance" {
  // transposition "ca" -> "ac" (1) + insert "b" (1) is 2 steps in Damerau-Levenshtein
  assert_eq(damerau_levenshtein_distance("ca", "abc"), 2)
  assert_eq(damerau_levenshtein_distance("ba", "ab"), 1)
  assert_eq(levenshtein_distance("ba", "ab"), 2)
}

///|
test "jaro winkler similarity" {
  let sim1 = jaro_similarity("dixon", "dicksonx")
  let sim2 = jaro_winkler_similarity("dixon", "dicksonx")
  assert_true(sim2 >= sim1)
  assert_true(jaro_winkler_similarity("martha", "marhta") > 0.9)
}

///|
test "sorensen dice coefficient" {
  let coeff = sorensen_dice_coefficient("night", "nacht")
  assert_true(coeff > 0.2)
  assert_eq(sorensen_dice_coefficient("abc", "abc"), 1.0)
}

///|
test "cosine similarity" {
  let text1 = "MoonBit is a fast language for modern cloud platforms"
  let text2 = "MoonBit is a very fast programming language for WebAssembly"
  let sim = cosine_similarity(text1, text2)
  assert_true(sim > 0.5)
  assert_true(sim < 1.0)
}

///|
test "overlap, tversky, jaccard and hamming string metrics" {
  let o = overlap_coefficient("night", "nacht")
  let tv = tversky_index("night", "nacht", 0.5, 0.5)
  let jac = string_jaccard_similarity("night", "nacht")
  let ham = string_hamming_distance("night", "nacht")

  assert_true(o >= 0.0 && o <= 1.0)
  assert_true(tv >= 0.0 && tv <= 1.0)
  assert_true(jac >= 0.0 && jac <= 1.0)
  assert_eq(ham, 2) // n-n (0), i-a (1), g-c (2), h-h (2), t-t (2)
}

///|
test "edge cases for similarity metrics" {
  // Empty inputs
  assert_eq(levenshtein_distance("", ""), 0)
  assert_eq(levenshtein_similarity("", ""), 1.0)
  assert_eq(damerau_levenshtein_distance("", ""), 0)
  assert_eq(jaro_similarity("", ""), 1.0)
  assert_eq(jaro_winkler_similarity("", ""), 1.0)
  assert_eq(sorensen_dice_coefficient("", ""), 1.0)
  assert_eq(cosine_similarity("", ""), 0.0)
  assert_eq(overlap_coefficient("", ""), 1.0)
  assert_eq(string_jaccard_similarity("", ""), 1.0)
  assert_eq(string_hamming_distance("", ""), 0)

  // Identical long sentences
  let long_s = "This is a long sentence used to verify that the metrics behave correctly under identity check."
  assert_eq(levenshtein_distance(long_s, long_s), 0)
  assert_eq(levenshtein_similarity(long_s, long_s), 1.0)
  assert_eq(damerau_levenshtein_distance(long_s, long_s), 0)
  assert_eq(jaro_similarity(long_s, long_s), 1.0)
  assert_eq(jaro_winkler_similarity(long_s, long_s), 1.0)
  assert_eq(sorensen_dice_coefficient(long_s, long_s), 1.0)
  assert_eq(cosine_similarity(long_s, long_s), 1.0)
  assert_eq(overlap_coefficient(long_s, long_s), 1.0)
  assert_eq(string_jaccard_similarity(long_s, long_s), 1.0)
  assert_eq(string_hamming_distance(long_s, long_s), 0)
}
