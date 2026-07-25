// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// CLI Entry point for moon-minhash similarity and deduplication tool.
fn main {
  println("==========================================================")
  println("  moon-minhash: MoonBit MinHash & Text Deduplication Suite")
  println("==========================================================")

  let text1 = "MoonBit is an end-to-end build tool and programming language system for WebAssembly"
  let text2 = "MoonBit is an end-to-end build tool and programming language system for WebAssembly targets"

  println("\n[1] MinHash Signature Generation:")
  let hasher = @minhash.MinHasher::new(64, 42UL)
  let sig1 = hasher.compute_text(text1)
  let sig2 = hasher.compute_text(text2)
  println("    Doc 1 Signature length: " + sig1.num_hashes.to_string())
  println("    Doc 2 Signature length: " + sig2.num_hashes.to_string())

  println("\n[2] Jaccard Similarity Estimation:")
  let sim = @minhash.jaccard_similarity(sig1, sig2)
  println("    Estimated Jaccard Similarity: " + sim.to_string())

  println("\n[3] b-bit Quantization (4-bit Compression):")
  let b1 = @compress.quantize_minhash(sig1, FourBit)
  let b2 = @compress.quantize_minhash(sig2, FourBit)
  let bbit_sim = @compress.bbit_jaccard_similarity(b1, b2)
  println("    b-bit Quantized Similarity: " + bbit_sim.to_string())

  println("\n[4] LSH Indexing & Candidate Query:")
  let lsh = @lsh.LSHIndex::new(16, 4)
  lsh.insert("doc_1", sig1)
  lsh.insert("doc_2", sig2)
  let cands = lsh.query_similar(sig1, 0.5)
  println(
    "    Matched Candidate Count (threshold >= 0.5): " +
    cands.length().to_string(),
  )

  println("\n[5] Batch Collection Deduplication:")
  let engine = @dedup.DeduplicationEngine::new(0.6, 64, 42UL)
  let docs = [
    @dedup.DocumentItem::new("d1", text1),
    @dedup.DocumentItem::new("d2", text2),
    @dedup.DocumentItem::new(
      "d3", "Unrelated document content about weather and outdoors",
    ),
  ]
  let report = engine.deduplicate_batch(docs)
  println("    Total Docs: " + report.total_documents.to_string())
  println("    Unique Docs: " + report.unique_documents.to_string())
  println("    Duplicates: " + report.duplicate_documents.to_string())
  println("==========================================================")
}
