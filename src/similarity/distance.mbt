// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Calculates standard Levenshtein (edit) distance between two strings using O(MN) space dynamic programming.
pub fn levenshtein_distance(s1 : String, s2 : String) -> Int {
  let len1 = s1.length()
  let len2 = s2.length()
  if len1 == 0 {
    return len2
  }
  if len2 == 0 {
    return len1
  }

  let dp = Array::make(len1 + 1, 0)
  let temp_dp = Array::make(len1 + 1, 0)
  for i = 0; i <= len1; i = i + 1 {
    dp[i] = i
  }

  for j = 1; j <= len2; j = j + 1 {
    let char2 = s2[j - 1]
    temp_dp[0] = j
    for i = 1; i <= len1; i = i + 1 {
      let char1 = s1[i - 1]
      let cost = if char1 == char2 { 0 } else { 1 }
      let deletion = dp[i] + 1
      let insertion = temp_dp[i - 1] + 1
      let substitution = dp[i - 1] + cost

      let mut min_val = deletion
      if insertion < min_val {
        min_val = insertion
      }
      if substitution < min_val {
        min_val = substitution
      }
      temp_dp[i] = min_val
    }
    // Copy temp_dp to dp
    for i = 0; i <= len1; i = i + 1 {
      dp[i] = temp_dp[i]
    }
  }

  dp[len1]
}

///|
/// Calculates Levenshtein similarity score between 0.0 and 1.0.
/// similarity = 1.0 - (levenshtein / max(len1, len2))
pub fn levenshtein_similarity(s1 : String, s2 : String) -> Double {
  let len1 = s1.length()
  let len2 = s2.length()
  let max_len = if len1 > len2 { len1 } else { len2 }
  if max_len == 0 {
    return 1.0
  }
  let dist = levenshtein_distance(s1, s2)
  1.0 - dist.to_double() / max_len.to_double()
}

///|
/// Calculates Damerau-Levenshtein distance (includes transposition of adjacent characters).
pub fn damerau_levenshtein_distance(s1 : String, s2 : String) -> Int {
  let len1 = s1.length()
  let len2 = s2.length()
  if len1 == 0 {
    return len2
  }
  if len2 == 0 {
    return len1
  }

  // Use a 2D matrix for full Damerau-Levenshtein calculation
  let d = Array::make((len1 + 2) * (len2 + 2), 0)

  fn get_d(i : Int, j : Int) -> Int {
    d[i * (len2 + 2) + j]
  }

  fn set_d(i : Int, j : Int, val : Int) -> Unit {
    d[i * (len2 + 2) + j] = val
  }

  let max_dist = len1 + len2
  set_d(0, 0, max_dist)
  for i = 0; i <= len1; i = i + 1 {
    set_d(i + 1, 0, max_dist)
    set_d(i + 1, 1, i)
  }
  for j = 0; j <= len2; j = j + 1 {
    set_d(0, j + 1, max_dist)
    set_d(1, j + 1, j)
  }

  // Track the last row index of each character to calculate transpositions
  let da = Map::from_array([])

  for i = 1; i <= len1; i = i + 1 {
    let mut db = 0
    let char1 = s1[i - 1]
    for j = 1; j <= len2; j = j + 1 {
      let char2 = s2[j - 1]
      let k = match da.get(char2.to_string()) {
        Some(val) => val
        None => 0
      }
      let l = db
      let cost = if char1 == char2 { 0 } else { 1 }
      if cost == 0 {
        db = j
      }

      let subst = get_d(i, j) + cost
      let insert = get_d(i + 1, j) + 1
      let delete = get_d(i, j + 1) + 1

      let mut min_val = subst
      if insert < min_val {
        min_val = insert
      }
      if delete < min_val {
        min_val = delete
      }

      // Transposition
      if k > 0 && l > 0 {
        let transp = get_d(k, l) + (i - k - 1) + 1 + (j - l - 1)
        if transp < min_val {
          min_val = transp
        }
      }

      set_d(i + 1, j + 1, min_val)
    }
    da.set(char1.to_string(), i)
  }

  get_d(len1 + 1, len2 + 1)
}

///|
/// Calculates the Jaro similarity score between two strings.
pub fn jaro_similarity(s1 : String, s2 : String) -> Double {
  let len1 = s1.length()
  let len2 = s2.length()
  if len1 == 0 && len2 == 0 {
    return 1.0
  }
  if len1 == 0 || len2 == 0 {
    return 0.0
  }

  let match_distance = (if len1 > len2 { len1 } else { len2 }) / 2 - 1
  let match_distance_clamped = if match_distance < 0 {
    0
  } else {
    match_distance
  }

  let s1_matches = Array::make(len1, false)
  let s2_matches = Array::make(len2, false)

  let mut matches = 0.0

  for i = 0; i < len1; i = i + 1 {
    let start = if i - match_distance_clamped < 0 {
      0
    } else {
      i - match_distance_clamped
    }
    let end = if i + match_distance_clamped + 1 > len2 {
      len2
    } else {
      i + match_distance_clamped + 1
    }

    for j = start; j < end; j = j + 1 {
      if s2_matches[j] {
        continue
      }
      if s1[i] == s2[j] {
        s1_matches[i] = true
        s2_matches[j] = true
        matches = matches + 1.0
        break
      }
    }
  }

  if matches == 0.0 {
    return 0.0
  }

  // Count transpositions
  let mut t = 0.0
  let mut k = 0
  for i = 0; i < len1; i = i + 1 {
    if !s1_matches[i] {
      continue
    }
    while !s2_matches[k] {
      k = k + 1
    }
    if s1[i] != s2[k] {
      t = t + 1.0
    }
    k = k + 1
  }

  let transpositions = t / 2.0
  (
    matches / len1.to_double() +
    matches / len2.to_double() +
    (matches - transpositions) / matches
  ) /
  3.0
}

///|
/// Calculates the Jaro-Winkler similarity score (bonus for common prefix up to 4 chars).
pub fn jaro_winkler_similarity(s1 : String, s2 : String) -> Double {
  let jaro = jaro_similarity(s1, s2)
  let p = 0.1
  let mut prefix_len = 0
  let min_len = if s1.length() < s2.length() {
    s1.length()
  } else {
    s2.length()
  }
  let max_prefix = if min_len > 4 { 4 } else { min_len }

  for i = 0; i < max_prefix; i = i + 1 {
    if s1[i] == s2[i] {
      prefix_len = prefix_len + 1
    } else {
      break
    }
  }

  jaro + prefix_len.to_double() * p * (1.0 - jaro)
}

///|
/// Calculates the Sorensen-Dice coefficient between two strings based on bigrams (pairs of adjacent characters).
pub fn sorensen_dice_coefficient(s1 : String, s2 : String) -> Double {
  let len1 = s1.length()
  let len2 = s2.length()
  if len1 < 2 || len2 < 2 {
    return if s1 == s2 { 1.0 } else { 0.0 }
  }

  let bigrams1 = Map::from_array([])
  let mut total_bigrams1 = 0
  for i = 0; i < len1 - 1; i = i + 1 {
    let bigram = s1[i:i + 2].to_owned()
    let count = match bigrams1.get(bigram) {
      Some(c) => c + 1
      None => 1
    }
    bigrams1.set(bigram, count)
    total_bigrams1 = total_bigrams1 + 1
  }

  let mut intersection = 0
  let mut total_bigrams2 = 0
  for i = 0; i < len2 - 1; i = i + 1 {
    let bigram = s2[i:i + 2].to_owned()
    total_bigrams2 = total_bigrams2 + 1
    match bigrams1.get(bigram) {
      Some(count) =>
        if count > 0 {
          intersection = intersection + 1
          bigrams1.set(bigram, count - 1)
        }
      None => ()
    }
  }

  2.0 *
  intersection.to_double() /
  (total_bigrams1.to_double() + total_bigrams2.to_double())
}

///|
/// Calculates Cosine Similarity between word frequency maps of two texts.
pub fn cosine_similarity(s1 : String, s2 : String) -> Double {
  // Simple word parser using whitespace split
  fn get_word_freq(s : String) -> Map[String, Int] {
    let freq = Map::from_array([])
    let len = s.length()
    let mut word = ""
    for i = 0; i < len; i = i + 1 {
      let c = s[i]
      if c == ' ' ||
        c == '\t' ||
        c == '\n' ||
        c == '\r' ||
        c == ',' ||
        c == '.' ||
        c == '?' ||
        c == '!' {
        if word.length() > 0 {
          let lower_word = word.to_lower()
          let count = match freq.get(lower_word) {
            Some(cnt) => cnt + 1
            None => 1
          }
          freq.set(lower_word, count)
          word = ""
        }
      } else {
        word = word + c.to_string()
      }
    }
    if word.length() > 0 {
      let lower_word = word.to_lower()
      let count = match freq.get(lower_word) {
        Some(cnt) => cnt + 1
        None => 1
      }
      freq.set(lower_word, count)
    }
    freq
  }

  let freq1 = get_word_freq(s1)
  let freq2 = get_word_freq(s2)

  let mut dot_product = 0.0
  let mut norm_a = 0.0
  let mut norm_b = 0.0

  for w, val in freq1 {
    let val_d = val.to_double()
    norm_a = norm_a + val_d * val_d
    match freq2.get(w) {
      Some(val2) => dot_product = dot_product + val_d * val2.to_double()
      None => ()
    }
  }

  for _, val in freq2 {
    let val_d = val.to_double()
    norm_b = norm_b + val_d * val_d
  }

  if norm_a == 0.0 || norm_b == 0.0 {
    return 0.0
  }

  dot_product / (norm_a.sqrt() * norm_b.sqrt())
}

///|
/// Calculates the Szymkiewicz-Simpson (overlap) coefficient between two strings based on bigrams.
pub fn overlap_coefficient(s1 : String, s2 : String) -> Double {
  let len1 = s1.length()
  let len2 = s2.length()
  if len1 < 2 || len2 < 2 {
    return if s1 == s2 { 1.0 } else { 0.0 }
  }

  let bigrams1 = Map::from_array([])
  let mut total_bigrams1 = 0
  for i = 0; i < len1 - 1; i = i + 1 {
    let bigram = s1[i:i + 2].to_owned()
    let count = match bigrams1.get(bigram) {
      Some(c) => c + 1
      None => 1
    }
    bigrams1.set(bigram, count)
    total_bigrams1 = total_bigrams1 + 1
  }

  let mut intersection = 0
  let mut total_bigrams2 = 0
  for i = 0; i < len2 - 1; i = i + 1 {
    let bigram = s2[i:i + 2].to_owned()
    total_bigrams2 = total_bigrams2 + 1
    match bigrams1.get(bigram) {
      Some(count) =>
        if count > 0 {
          intersection = intersection + 1
          bigrams1.set(bigram, count - 1)
        }
      None => ()
    }
  }

  let min_total = if total_bigrams1 < total_bigrams2 {
    total_bigrams1
  } else {
    total_bigrams2
  }
  if min_total == 0 {
    return 0.0
  }
  intersection.to_double() / min_total.to_double()
}

///|
/// Calculates the Tversky Index between two strings based on bigrams.
/// Tversky index is an asymmetric similarity measure on sets.
pub fn tversky_index(
  s1 : String,
  s2 : String,
  alpha : Double,
  beta : Double,
) -> Double {
  let len1 = s1.length()
  let len2 = s2.length()
  if len1 < 2 || len2 < 2 {
    return if s1 == s2 { 1.0 } else { 0.0 }
  }

  let bigrams1 = Map::from_array([])
  let mut total_bigrams1 = 0
  for i = 0; i < len1 - 1; i = i + 1 {
    let bigram = s1[i:i + 2].to_owned()
    let count = match bigrams1.get(bigram) {
      Some(c) => c + 1
      None => 1
    }
    bigrams1.set(bigram, count)
    total_bigrams1 = total_bigrams1 + 1
  }

  let mut intersection = 0
  let mut total_bigrams2 = 0
  for i = 0; i < len2 - 1; i = i + 1 {
    let bigram = s2[i:i + 2].to_owned()
    total_bigrams2 = total_bigrams2 + 1
    match bigrams1.get(bigram) {
      Some(count) =>
        if count > 0 {
          intersection = intersection + 1
          bigrams1.set(bigram, count - 1)
        }
      None => ()
    }
  }

  let a_minus_b = total_bigrams1 - intersection
  let b_minus_a = total_bigrams2 - intersection

  let denom = intersection.to_double() +
    alpha * a_minus_b.to_double() +
    beta * b_minus_a.to_double()
  if denom == 0.0 {
    return 0.0
  }
  intersection.to_double() / denom
}

///|
/// Calculates Jaccard similarity score on character level.
pub fn string_jaccard_similarity(s1 : String, s2 : String) -> Double {
  let len1 = s1.length()
  let len2 = s2.length()
  if len1 == 0 && len2 == 0 {
    return 1.0
  }
  if len1 == 0 || len2 == 0 {
    return 0.0
  }

  let set1 = Map::from_array([])
  for i = 0; i < len1; i = i + 1 {
    set1.set(s1[i].to_string(), true)
  }

  let mut intersection = 0
  let set2 = Map::from_array([])
  for i = 0; i < len2; i = i + 1 {
    let char_str = s2[i].to_string()
    if !set2.contains(char_str) {
      set2.set(char_str, true)
      if set1.contains(char_str) {
        intersection = intersection + 1
      }
    }
  }

  let union_cnt = set1.length() + set2.length() - intersection
  if union_cnt == 0 {
    return 0.0
  }
  intersection.to_double() / union_cnt.to_double()
}

///|
/// Calculates Hamming distance between two string sequences of equal length.
pub fn string_hamming_distance(s1 : String, s2 : String) -> Int {
  let len1 = s1.length()
  let len2 = s2.length()
  let min_len = if len1 < len2 { len1 } else { len2 }
  let mut dist = (len1 - len2).abs()

  for i = 0; i < min_len; i = i + 1 {
    if s1[i] != s2[i] {
      dist = dist + 1
    }
  }
  dist
}
