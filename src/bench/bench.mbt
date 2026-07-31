// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
let vocabulary : Array[String] = [
  "moonbit", "language", "fast", "safe", "efficient", "compiler", "wasm", "webassembly",
  "native", "hashing", "minhash", "similarity", "deduplication", "engine", "cluster",
  "document", "database", "index", "performance", "benchmark", "accuracy", "collision",
  "algorithm", "system", "structure", "module", "package", "tokenizer", "shingle",
  "rabin", "cdc", "vector", "matrix", "distance", "levenshtein", "cosine", "dice",
  "jaccard", "tversky", "overlap", "hamming", "fingerprint", "simhash", "lsh", "hyperloglog",
  "cardinality", "compression", "quantization", "bit", "storage", "shard", "partition",
  "parallel", "union", "find", "graph", "tree", "merge",
]

///|
fn generate_random_doc(seed : UInt64, word_count : Int) -> String {
  let mut prng_state = seed
  // PCG-XSH-RR 64/32 PRNG for random word selection
  fn next_random_idx(state : UInt64) -> (UInt64, Int) {
    let next_state = state * 6364136223846793005UL + 1442695040888963407UL
    let xorshifted = (((next_state >> 18) ^ next_state) >> 27).to_uint()
    let rot = (next_state >> 59).to_uint()
    let rot_int = rot.reinterpret_as_int()
    let rot_val = (xorshifted >> rot_int) |
      (xorshifted << ((rot_int * -1) & 31))
    let idx = rot_val.reinterpret_as_int().abs() % vocabulary.length()
    (next_state, idx)
  }

  let mut doc = ""
  for i = 0; i < word_count; i = i + 1 {
    let (next_state, idx) = next_random_idx(prng_state)
    prng_state = next_state
    if i > 0 {
      doc = doc + " "
    }
    doc = doc + vocabulary[idx]
  }
  doc
}

///|
/// Executes synthetic benchmark workloads across hash, tokenizer, minhash, lsh, compress, shard, and dedup.
pub fn run_all_benchmarks() -> Unit {
  // 1. Core verification workload
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

  // 2. Hash Speed Benchmark simulation
  let mut sum_hash = 0U
  let docs_count = 100
  for i = 0; i < docs_count; i = i + 1 {
    let doc = generate_random_doc(i.to_uint64() + 1000UL, 30)
    sum_hash = sum_hash ^ @hash.murmurhash3_32_str(doc, i.reinterpret_as_uint())
    sum_hash = sum_hash ^ @hash.xxhash32_str(doc, i.reinterpret_as_uint())
    sum_hash = sum_hash ^ @hash.fnv1a_32_str(doc)
  }

  // 3. Distance Metrics Benchmarking
  let mut sum_sim = 0.0
  for i = 0; i < 20; i = i + 1 {
    let doc1 = generate_random_doc(i.to_uint64() * 2UL, 15)
    let doc2 = generate_random_doc(i.to_uint64() * 2UL + 1UL, 15)
    sum_sim = sum_sim + @similarity.levenshtein_similarity(doc1, doc2)
    sum_sim = sum_sim + @similarity.jaro_winkler_similarity(doc1, doc2)
    sum_sim = sum_sim + @similarity.sorensen_dice_coefficient(doc1, doc2)
    sum_sim = sum_sim + @similarity.cosine_similarity(doc1, doc2)
    sum_sim = sum_sim + @similarity.overlap_coefficient(doc1, doc2)
  }

  // 4. LSH Indexing and Clustering simulation
  let lsh_sim = @lsh.LSHIndex::new(16, 4)
  for i = 0; i < 50; i = i + 1 {
    let doc = generate_random_doc(i.to_uint64() * 99UL + 42UL, 25)
    let sig_doc = hasher.compute_text(doc)
    lsh_sim.insert("doc_" + i.to_string(), sig_doc)
  }

  // Prevent dead code elimination
  let _ = sum_hash
  let _ = sum_sim
}
