// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Batch document collection deduplication engine & statistics report generator.
pub struct DocumentItem {
  id : String
  content : String
}

///|
pub fn DocumentItem::new(id : String, content : String) -> DocumentItem {
  { id, content }
}

///|
pub struct DedupReport {
  total_documents : Int
  unique_documents : Int
  duplicate_documents : Int
  dedup_ratio : Double
  clusters : Map[String, Array[String]]
}

///|
pub struct DeduplicationEngine {
  threshold : Double
  num_hashes : Int
  seed : UInt64
}

///|
pub fn DeduplicationEngine::new(
  threshold : Double,
  num_hashes : Int,
  seed : UInt64,
) -> DeduplicationEngine {
  { threshold, num_hashes, seed }
}

///|
/// Deduplicates a batch collection of document items.
pub fn DeduplicationEngine::deduplicate_batch(
  self : DeduplicationEngine,
  documents : Array[DocumentItem],
) -> DedupReport {
  let streamer = StreamingDeduplicator::new(
    self.threshold,
    self.num_hashes,
    self.seed,
  )
  let cluster_system = DisjointSetCluster::new()

  let mut duplicates_cnt = 0
  let total_cnt = documents.length()

  for i = 0; i < total_cnt; i = i + 1 {
    let doc = documents[i]
    let res = streamer.process(doc.id, doc.content)
    if res.is_duplicate {
      duplicates_cnt = duplicates_cnt + 1
      cluster_system.union(doc.id, res.matched_doc_id)
    } else {
      cluster_system.find(doc.id) |> ignore
    }
  }

  let unique_cnt = total_cnt - duplicates_cnt
  let ratio = if total_cnt > 0 {
    duplicates_cnt.to_double() / total_cnt.to_double()
  } else {
    0.0
  }

  {
    total_documents: total_cnt,
    unique_documents: unique_cnt,
    duplicate_documents: duplicates_cnt,
    dedup_ratio: ratio,
    clusters: cluster_system.get_clusters(),
  }
}
