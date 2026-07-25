// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Tokenizer types: Character N-grams, Word N-grams, and CJK tokenization.
pub enum TokenizerType {
  CharNGram(Int)
  WordNGram(Int)
  CJKCharNGram(Int)
}

///|
/// Splits text into words separated by spaces.
pub fn split_words(text : String) -> Array[String] {
  let result = Array::new()
  let buf = StringBuilder::new()

  for ch in text {
    if ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' {
      if !buf.is_empty() {
        result.push(buf.to_string())
        buf.reset()
      }
    } else {
      buf.write_char(ch)
    }
  }
  if !buf.is_empty() {
    result.push(buf.to_string())
  }
  result
}

///|
/// Generates character n-grams of specified size n.
pub fn char_ngrams(text : String, n : Int) -> Array[String] {
  let len = text.length()
  if len < n || n <= 0 {
    if len > 0 {
      return [text]
    } else {
      return []
    }
  }

  let result = Array::new(capacity=len - n + 1)
  for i = 0; i <= len - n; i = i + 1 {
    result.push(text[i:i + n].to_owned())
  }
  result
}

///|
/// Generates word n-grams of specified size n from text.
pub fn word_ngrams(text : String, n : Int) -> Array[String] {
  let words = split_words(text)
  let word_count = words.length()
  if word_count < n || n <= 0 {
    if word_count > 0 {
      let sb = StringBuilder::new()
      for i = 0; i < word_count; i = i + 1 {
        if i > 0 {
          sb.write_char(' ')
        }
        sb.write_string(words[i])
      }
      return [sb.to_string()]
    } else {
      return []
    }
  }

  let result = Array::new(capacity=word_count - n + 1)
  for i = 0; i <= word_count - n; i = i + 1 {
    let sb = StringBuilder::new()
    for j = 0; j < n; j = j + 1 {
      if j > 0 {
        sb.write_char(' ')
      }
      sb.write_string(words[i + j])
    }
    result.push(sb.to_string())
  }
  result
}

///|
/// Tokenizes text into tokens using configured TokenizerType.
pub fn tokenize(text : String, tokenizer_type : TokenizerType) -> Array[String] {
  let norm = normalize_text(text, NormalizerConfig::default())
  match tokenizer_type {
    CharNGram(n) => char_ngrams(norm, n)
    WordNGram(n) => word_ngrams(norm, n)
    CJKCharNGram(n) => char_ngrams(norm, n)
  }
}
