// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Normalizes input text by converting characters to lowercase,
/// collapsing multiple whitespace characters, and optionally stripping punctuation.
pub struct NormalizerConfig {
  lowercase : Bool
  strip_punctuation : Bool
  strip_digits : Bool
  normalize_whitespace : Bool
}

///|
pub fn NormalizerConfig::default() -> NormalizerConfig {
  {
    lowercase: true,
    strip_punctuation: false,
    strip_digits: false,
    normalize_whitespace: true,
  }
}

///|
pub fn normalize_text(text : String, config : NormalizerConfig) -> String {
  let buf = StringBuilder::new()
  let mut in_space = false

  for ch in text {
    let code = ch.to_int()

    if is_whitespace(code) {
      if config.normalize_whitespace {
        if !in_space && !buf.is_empty() {
          buf.write_char(' ')
          in_space = true
        }
      } else {
        buf.write_char(ch)
      }
    } else if config.strip_punctuation && is_punctuation(code) {
      ()
    } else if config.strip_digits && is_digit(code) {
      ()
    } else {
      in_space = false
      if config.lowercase {
        buf.write_char(to_lower_char(ch))
      } else {
        buf.write_char(ch)
      }
    }
  }

  let result = buf.to_string()
  let len = result.length()
  if len > 0 && result[len - 1] == ' ' {
    result[0:len - 1].to_owned()
  } else {
    result
  }
}

///|
fn is_whitespace(code : Int) -> Bool {
  code == 32 || code == 9 || code == 10 || code == 13
}

///|
fn is_punctuation(code : Int) -> Bool {
  (code >= 33 && code <= 47) ||
  (code >= 58 && code <= 64) ||
  (code >= 91 && code <= 96) ||
  (code >= 123 && code <= 126)
}

///|
fn is_digit(code : Int) -> Bool {
  code >= 48 && code <= 57
}

///|
fn to_lower_char(ch : Char) -> Char {
  let code = ch.to_int()
  if code >= 65 && code <= 90 {
    (code + 32).unsafe_to_char()
  } else {
    ch
  }
}
