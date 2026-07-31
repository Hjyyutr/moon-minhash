// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// A standard Porter Stemmer implementation in native MoonBit.
/// Stemming is the process of reducing inflected (or sometimes derived) words to their word stem.
pub struct PorterStemmer {
  // Empty struct for namespace/organization
}

///|
pub fn PorterStemmer::new() -> PorterStemmer {
  PorterStemmer::{  }
}

///|
fn get_char(word : String, i : Int) -> Char {
  word[i].to_int().unsafe_to_char()
}

///|
fn is_vowel_char(c : Char) -> Bool {
  c == 'a' ||
  c == 'e' ||
  c == 'i' ||
  c == 'o' ||
  c == 'u' ||
  c == 'A' ||
  c == 'E' ||
  c == 'I' ||
  c == 'O' ||
  c == 'U'
}

///|
pub fn is_consonant(word : String, i : Int) -> Bool {
  if i < 0 || i >= word.length() {
    return false
  }
  let c = get_char(word, i)
  if is_vowel_char(c) {
    false
  } else if c == 'y' || c == 'Y' {
    if i == 0 {
      true
    } else {
      let prev_c = get_char(word, i - 1)
      is_vowel_char(prev_c) // Y is consonant if preceded by vowel
    }
  } else {
    true
  }
}

///|
/// Computes the measure m of a word stem up to end_idx.
/// The measure m is the number of VC (Vowel-Consonant) sequences.
pub fn get_measure(word : String, end_idx : Int) -> Int {
  let mut m = 0
  let mut i = 0

  // Skip leading consonants
  while i <= end_idx && is_consonant(word, i) {
    i = i + 1
  }

  while i <= end_idx {
    if !is_consonant(word, i) {
      // Found vowel
      while i <= end_idx && !is_consonant(word, i) {
        i = i + 1
      }
      if i <= end_idx && is_consonant(word, i) {
        m = m + 1
        i = i + 1
        while i <= end_idx && is_consonant(word, i) {
          i = i + 1
        }
      }
    } else {
      i = i + 1
    }
  }
  m
}

///|
fn has_vowel_in_stem(word : String, end_idx : Int) -> Bool {
  for i = 0; i <= end_idx; i = i + 1 {
    if !is_consonant(word, i) {
      return true
    }
  }
  false
}

///|
fn ends_with_double_consonant(word : String, end_idx : Int) -> Bool {
  if end_idx < 1 {
    return false
  }
  let c1 = get_char(word, end_idx)
  let c2 = get_char(word, end_idx - 1)
  if c1 != c2 {
    return false
  }
  is_consonant(word, end_idx)
}

///|
/// Checks if the stem ends in cvc, where the second c is not w, x or y.
fn cvc_stem(word : String, end_idx : Int) -> Bool {
  if end_idx < 2 {
    return false
  }
  if is_consonant(word, end_idx) &&
    !is_consonant(word, end_idx - 1) &&
    is_consonant(word, end_idx - 2) {
    let c = get_char(word, end_idx)
    if c != 'w' && c != 'x' && c != 'y' && c != 'W' && c != 'X' && c != 'Y' {
      return true
    }
  }
  false
}

///|
/// Stems an English word to its root form.
pub fn PorterStemmer::stem(self : PorterStemmer, word : String) -> String {
  let len = word.length()
  if len <= 2 {
    return word
  }

  // Create mutable buffer of characters
  let mut s = ""
  for i = 0; i < len; i = i + 1 {
    let c = get_char(word, i)
    // Stemmer works on lower-case characters
    let lower_c = if c >= 'A' && c <= 'Z' {
      (c.to_int() - 'A'.to_int() + 'a'.to_int()).unsafe_to_char()
    } else {
      c
    }
    s = s + lower_c.to_string()
  }

  let end = s.length() - 1

  // Helper local functions to slice and set strings
  fn replace_suffix(
    str : String,
    suffix : String,
    repl : String,
    cur_end : Int,
  ) -> (String, Int, Bool) {
    let slen = suffix.length()
    let start = cur_end - slen + 1
    if start >= 0 && str[start:cur_end + 1].to_owned() == suffix {
      let stem = str[0:start].to_owned()
      let next_str = stem + repl
      let next_end = next_str.length() - 1
      (next_str, next_end, true)
    } else {
      (str, cur_end, false)
    }
  }

  // --- Step 1a ---
  let (s1a, end1a, ok1a) = replace_suffix(s, "sses", "ss", end)
  let (s1a, end1a) = if ok1a {
    (s1a, end1a)
  } else {
    let (s_ies, end_ies, ok_ies) = replace_suffix(s, "ies", "i", end)
    if ok_ies {
      (s_ies, end_ies)
    } else {
      let (s_ss, end_ss, ok_ss) = replace_suffix(s, "ss", "ss", end)
      if ok_ss {
        (s_ss, end_ss)
      } else {
        let (s_s, end_s, ok_s) = replace_suffix(s, "s", "", end)
        if ok_s && end_s >= 0 && get_char(s_s, end_s) != 's' {
          (s_s, end_s)
        } else {
          (s, end)
        }
      }
    }
  }
  let mut s_step = s1a
  let mut end_step = end1a

  // --- Step 1b ---
  let mut step1b_extra = false
  let (s1b, end1b, ok1b) = replace_suffix(s_step, "eed", "ee", end_step)
  let (s1b, end1b) = if ok1b {
    if get_measure(s1b, end1b - 2) > 0 {
      (s1b, end1b)
    } else {
      (s_step, end_step)
    }
  } else {
    let (s_ed, end_ed, ok_ed) = replace_suffix(s_step, "ed", "", end_step)
    if ok_ed && has_vowel_in_stem(s_ed, end_ed) {
      step1b_extra = true
      (s_ed, end_ed)
    } else {
      let (s_ing, end_ing, ok_ing) = replace_suffix(s_step, "ing", "", end_step)
      if ok_ing && has_vowel_in_stem(s_ing, end_ing) {
        step1b_extra = true
        (s_ing, end_ing)
      } else {
        (s_step, end_step)
      }
    }
  }

  s_step = s1b
  end_step = end1b

  if step1b_extra {
    let (s_at, end_at, ok_at) = replace_suffix(s_step, "at", "ate", end_step)
    if ok_at {
      s_step = s_at
      end_step = end_at
    } else {
      let (s_bl, end_bl, ok_bl) = replace_suffix(s_step, "bl", "ble", end_step)
      if ok_bl {
        s_step = s_bl
        end_step = end_bl
      } else {
        let (s_iz, end_iz, ok_iz) = replace_suffix(
          s_step, "iz", "ize", end_step,
        )
        if ok_iz {
          s_step = s_iz
          end_step = end_iz
        } else if ends_with_double_consonant(s_step, end_step) {
          let c = get_char(s_step, end_step)
          if c != 'l' && c != 's' && c != 'z' {
            s_step = s_step[0:end_step].to_owned()
            end_step = end_step - 1
          }
        } else if get_measure(s_step, end_step) == 1 &&
          cvc_stem(s_step, end_step) {
          s_step = s_step + "e"
          end_step = end_step + 1
        }
      }
    }
  }

  // --- Step 1c ---
  let (s1c, end1c, ok1c) = replace_suffix(s_step, "y", "i", end_step)
  if ok1c && has_vowel_in_stem(s1c, end1c - 1) {
    s_step = s1c
    end_step = end1c
  }

  // --- Step 2 ---
  let suffixes2 = [
    ("ational", "ate"),
    ("tional", "tion"),
    ("enci", "ence"),
    ("anci", "ance"),
    ("izer", "ize"),
    ("bli", "ble"),
    ("alli", "al"),
    ("entli", "ent"),
    ("eli", "e"),
    ("ousli", "ous"),
    ("ization", "ize"),
    ("ation", "ate"),
    ("ator", "ate"),
    ("alism", "al"),
    ("iveness", "ive"),
    ("fulness", "ful"),
    ("ousness", "ous"),
    ("aliti", "al"),
    ("iviti", "ive"),
    ("biliti", "ble"),
  ]
  for i = 0; i < suffixes2.length(); i = i + 1 {
    let (suff, repl) = suffixes2[i]
    let slen = suff.length()
    let start = end_step - slen + 1
    if start >= 0 && s_step[start:end_step + 1].to_owned() == suff {
      if get_measure(s_step, start - 1) > 0 {
        s_step = s_step[0:start].to_owned() + repl
        end_step = s_step.length() - 1
      }
      break
    }
  }

  let suffixes3 = [
    ("icate", "ic"),
    ("alize", "al"),
    ("iciti", "ic"),
    ("ical", "ic"),
    ("ful", ""),
    ("ness", ""),
  ]
  for i = 0; i < suffixes3.length(); i = i + 1 {
    let (suff, repl) = suffixes3[i]
    let slen = suff.length()
    let start = end_step - slen + 1
    if start >= 0 && s_step[start:end_step + 1].to_owned() == suff {
      if get_measure(s_step, start - 1) > 0 {
        s_step = s_step[0:start].to_owned() + repl
        end_step = s_step.length() - 1
      }
      break
    }
  }

  // --- Step 4 ---
  let suffixes4 = [
    "al", "ance", "ence", "er", "ic", "able", "ible", "ant", "ement", "ment", "ent",
    "ou", "ism", "ate", "iti", "ous", "ive", "ize", "ist",
  ]
  let mut step4_done = false
  for i = 0; i < suffixes4.length(); i = i + 1 {
    let suff = suffixes4[i]
    let slen = suff.length()
    let start = end_step - slen + 1
    if start >= 0 && s_step[start:end_step + 1].to_owned() == suff {
      if get_measure(s_step, start - 1) > 1 {
        s_step = s_step[0:start].to_owned()
        end_step = s_step.length() - 1
        step4_done = true
      }
      break
    }
  }

  if !step4_done {
    let slen = 3 // "ion"
    let start = end_step - slen + 1
    if start >= 0 && s_step[start:end_step + 1].to_owned() == "ion" {
      if start > 0 {
        let c = get_char(s_step, start - 1)
        if (c == 's' || c == 't') && get_measure(s_step, start - 1) > 1 {
          s_step = s_step[0:start].to_owned()
          end_step = s_step.length() - 1
        }
      }
    }
  }

  // --- Step 5a ---
  if end_step > 0 && get_char(s_step, end_step) == 'e' {
    let m_val = get_measure(s_step, end_step - 1)
    if m_val > 1 || (m_val == 1 && !cvc_stem(s_step, end_step - 1)) {
      s_step = s_step[0:end_step].to_owned()
      end_step = end_step - 1
    }
  }

  // --- Step 5b ---
  if end_step > 0 &&
    get_char(s_step, end_step) == 'l' &&
    ends_with_double_consonant(s_step, end_step) {
    if get_measure(s_step, end_step) > 1 {
      s_step = s_step[0:end_step].to_owned()
      // end_step = end_step - 1
    }
  }

  // Self is unused, but required by method signature
  let _ = self
  s_step
}
