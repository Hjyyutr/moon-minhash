// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// HyperLogLog cardinality estimator for distinct set element count & set similarity.
pub struct HyperLogLog {
  p : Int
  m : Int
  registers : FixedArray[Byte]
  alpha_m : Double
}

///|
pub fn HyperLogLog::new(p : Int) -> HyperLogLog {
  let valid_p = if p < 4 { 4 } else if p > 16 { 16 } else { p }
  let m = 1 << valid_p
  let registers = FixedArray::make(m, (0).to_byte())

  let alpha = match valid_p {
    4 => 0.673
    5 => 0.697
    6 => 0.709
    _ => 0.7213 / (1.0 + 1.079 / m.to_double())
  }
  let alpha_m = alpha * m.to_double() * m.to_double()

  { p: valid_p, m, registers, alpha_m }
}

///|
/// Adds a hashed element to HyperLogLog register sketch.
pub fn HyperLogLog::add(self : HyperLogLog, hash_val : UInt) -> Unit {
  let idx = (hash_val >> (32 - self.p)).reinterpret_as_int()
  let w = (hash_val << self.p) | (1U << (self.p - 1))
  let rho = count_leading_zeros(w) + 1

  if rho.to_byte() > self.registers[idx] {
    self.registers[idx] = rho.to_byte()
  }
}

///|
/// Adds string item by hashing with MurmurHash3.
pub fn HyperLogLog::add_string(self : HyperLogLog, text : String) -> Unit {
  let h = @hash.murmurhash3_32_str(text, 42U)
  self.add(h)
}

///|
/// Estimates distinct element cardinality.
pub fn HyperLogLog::cardinality(self : HyperLogLog) -> Double {
  let mut sum = 0.0
  let mut zeros = 0
  for i = 0; i < self.m; i = i + 1 {
    let r = self.registers[i].to_int()
    if r == 0 {
      zeros = zeros + 1
    }
    let mut pow2 = 1.0
    for k = 0; k < r; k = k + 1 {
      pow2 = pow2 * 0.5
    }
    sum = sum + pow2
  }

  let mut estimate = self.alpha_m / sum
  if estimate <= 2.5 * self.m.to_double() && zeros > 0 {
    let ratio = self.m.to_double() / zeros.to_double()
    estimate = self.m.to_double() * ln_approx(ratio)
  }
  estimate
}

///|
/// Merges another HyperLogLog sketch into self (register-wise maximum).
pub fn HyperLogLog::merge(self : HyperLogLog, other : HyperLogLog) -> Unit {
  if self.m != other.m {
    return
  }
  for i = 0; i < self.m; i = i + 1 {
    if other.registers[i] > self.registers[i] {
      self.registers[i] = other.registers[i]
    }
  }
}

///|
fn ln_approx(x : Double) -> Double {
  if x <= 0.0 {
    return 0.0
  }
  let z = (x - 1.0) / (x + 1.0)
  let z2 = z * z
  2.0 * z * (1.0 + z2 / 3.0 + z2 * z2 / 5.0 + z2 * z2 * z2 / 7.0)
}

///|
fn count_leading_zeros(v : UInt) -> Int {
  if v == 0U {
    return 32
  }
  let mut x = v
  let mut n = 0
  if (x & 0xffff0000U) == 0U {
    n = n + 16
    x = x << 16
  }
  if (x & 0xff000000U) == 0U {
    n = n + 8
    x = x << 8
  }
  if (x & 0xf0000000U) == 0U {
    n = n + 4
    x = x << 4
  }
  if (x & 0xc0000000U) == 0U {
    n = n + 2
    x = x << 2
  }
  if (x & 0x80000000U) == 0U {
    n = n + 1
  }
  n
}
