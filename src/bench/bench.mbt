// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Executes synthetic benchmark workloads across hash, tokenizer, minhash, lsh, compress, shard, and dedup.
pub fn run_all_benchmarks() -> Unit {
  let sample = "MoonBit fast non-cryptographic hashing algorithm evaluation payload"
  let h1 = @hash.murmurhash3_32_str(sample, 42U)
  let _ = @hash.xxhash32_str(sample, 42U)

  let tokens = @tokenizer.tokenize(sample, CharNGram(3))
  let hasher = @minhash.MinHasher::new(64, 42UL)
  let sig = hasher.compute_tokens([h1])

  let lsh_idx = @lsh.LSHIndex::new(8, 8)
  lsh_idx.insert("d1", sig)

  let bbit = @compress.quantize_minhash(sig, FourBit)
  let _ = @compress.bbit_jaccard_similarity(bbit, bbit)

  let shard = @shard.ShardPartition::new(0, 8, 8)
  shard.insert("d1", sig)

  let streamer = @dedup.StreamingDeduplicator::new(0.5, 64, 42UL)
  let _ = streamer.process("d1", sample)
  let _ = tokens.length()
}
