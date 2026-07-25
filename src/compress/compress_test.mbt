// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
test "bbit minhash quantization 1bit" {
  let sig = @minhash.MinHashSignature::from_values([
    1U, 2U, 3U, 4U, 5U, 6U, 7U, 8U,
  ])
  let bbit_sig = quantize_minhash(sig, BBitMode::OneBit)
  assert_eq(bbit_sig.num_hashes, 8)
  assert_eq(bbit_sig.packed_data.length(), 1)
}

///|
test "bbit minhash quantization 2bit" {
  let sig = @minhash.MinHashSignature::from_values([1U, 2U, 3U, 4U])
  let bbit_sig = quantize_minhash(sig, BBitMode::TwoBit)
  assert_eq(bbit_sig.num_hashes, 4)
  assert_eq(bbit_sig.packed_data.length(), 1)
}

///|
test "bbit jaccard similarity" {
  let sig1 = @minhash.MinHashSignature::from_values([
    1U, 2U, 3U, 4U, 5U, 6U, 7U, 8U,
  ])
  let sig2 = @minhash.MinHashSignature::from_values([
    1U, 2U, 3U, 4U, 5U, 6U, 7U, 8U,
  ])
  let b1 = quantize_minhash(sig1, BBitMode::FourBit)
  let b2 = quantize_minhash(sig2, BBitMode::FourBit)

  let sim = bbit_jaccard_similarity(b1, b2)
  assert_eq(sim, 1.0)
}

///|
test "hyperloglog cardinality estimation" {
  let hll = HyperLogLog::new(10)
  for i = 0; i < 1000; i = i + 1 {
    let hash_val = @hash.murmurhash3_32_str(i.to_string(), 42U)
    hll.add(hash_val)
  }

  let est = hll.cardinality()
  assert_true(est > 800.0)
  assert_true(est < 1200.0)
}
