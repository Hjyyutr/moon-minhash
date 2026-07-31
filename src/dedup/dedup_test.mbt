// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
test "union find cluster" {
  let cluster = DisjointSetCluster::new()
  cluster.union("d1", "d2")
  cluster.union("d2", "d3")
  cluster.union("d4", "d5")

  assert_eq(cluster.find("d1"), cluster.find("d3"))
  assert_true(cluster.find("d1") != cluster.find("d4"))
  assert_true(cluster.has_element("d1"))
  assert_eq(cluster.length(), 5)

  let docs = cluster.to_array()
  assert_eq(docs.length(), 5)
}

///|
test "hierarchical merge union find cluster" {
  let edges = [("d1", "d2"), ("d2", "d3"), ("d4", "d5")]
  let cluster = hierarchical_merge_cluster(edges, 2)

  assert_eq(cluster.find("d1"), cluster.find("d3"))
  assert_true(cluster.find("d1") != cluster.find("d4"))
}

///|
test "streaming deduplicator" {
  let deduper = StreamingDeduplicator::new(0.4, 128, 42UL)

  let t1 = "MoonBit is a high performance build tool and programming language system for WebAssembly and native cloud services"
  let t2 = "MoonBit is a high performance build tool and programming language system for WebAssembly and native cloud platform"
  let t3 = "Rust is a systems programming language with memory safety without garbage collection"

  let r1 = deduper.process("doc1", t1)
  assert_false(r1.is_duplicate)

  let r2 = deduper.process("doc2", t2)
  assert_true(r2.is_duplicate)
  assert_eq(r2.matched_doc_id, "doc1")

  let r3 = deduper.process("doc3", t3)
  assert_false(r3.is_duplicate)
}

///|
test "batch deduplication engine" {
  let engine = DeduplicationEngine::new(0.4, 128, 42UL)
  let docs = [
    DocumentItem::new(
      "d1", "MoonBit releases major update for compiler build performance and code generation speed",
    ),
    DocumentItem::new(
      "d2", "MoonBit releases major update for compiler build performance and code generation fast",
    ),
    DocumentItem::new(
      "d3", "Weather forecast predicts sunny skies and warm temperature for weekend trip",
    ),
  ]

  let report = engine.deduplicate_batch(docs)
  assert_eq(report.total_documents, 3)
  assert_eq(report.duplicate_documents, 1)
  assert_eq(report.unique_documents, 2)
}
