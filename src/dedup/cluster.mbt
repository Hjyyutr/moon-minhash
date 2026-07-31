// Copyright 2026 Hjyyutr
// Licensed under the Apache License, Version 2.0

///|
/// Union-Find Disjoint Set Cluster system for grouping near-duplicate document graphs.
pub struct DisjointSetCluster {
  parent : Map[String, String]
  rank : Map[String, Int]
}

///|
pub fn DisjointSetCluster::new() -> DisjointSetCluster {
  { parent: Map::from_array([]), rank: Map::from_array([]) }
}

///|
/// Checks if an element exists in the disjoint set cluster.
pub fn DisjointSetCluster::has_element(
  self : DisjointSetCluster,
  x : String,
) -> Bool {
  self.parent.contains(x)
}

///|
/// Returns the total number of tracked elements in the disjoint set cluster.
pub fn DisjointSetCluster::length(self : DisjointSetCluster) -> Int {
  self.parent.length()
}

///|
/// Clears all cluster assignments.
pub fn DisjointSetCluster::clear(self : DisjointSetCluster) -> Unit {
  self.parent.clear()
  self.rank.clear()
}

///|
/// Returns an array of all tracked document IDs in the cluster.
pub fn DisjointSetCluster::to_array(self : DisjointSetCluster) -> Array[String] {
  let arr = Array::new()
  for x, _ in self.parent {
    arr.push(x)
  }
  arr
}

///|
/// Finds root representative for element x with path compression.
pub fn DisjointSetCluster::find(
  self : DisjointSetCluster,
  x : String,
) -> String {
  if !self.parent.contains(x) {
    self.parent.set(x, x)
    self.rank.set(x, 0)
    return x
  }

  match self.parent.get(x) {
    Some(p) =>
      if p == x {
        x
      } else {
        let root = self.find(p)
        self.parent.set(x, root)
        root
      }
    None => x
  }
}

///|
/// Unites sets containing x and y by rank.
pub fn DisjointSetCluster::union(
  self : DisjointSetCluster,
  x : String,
  y : String,
) -> Unit {
  let root_x = self.find(x)
  let root_y = self.find(y)

  if root_x != root_y {
    let rank_x = match self.rank.get(root_x) {
      Some(r) => r
      None => 0
    }
    let rank_y = match self.rank.get(root_y) {
      Some(r) => r
      None => 0
    }

    if rank_x < rank_y {
      self.parent.set(root_x, root_y)
    } else if rank_x > rank_y {
      self.parent.set(root_y, root_x)
    } else {
      self.parent.set(root_y, root_x)
      self.rank.set(root_x, rank_x + 1)
    }
  }
}

///|
/// Groups document IDs by cluster root representative.
pub fn DisjointSetCluster::get_clusters(
  self : DisjointSetCluster,
) -> Map[String, Array[String]] {
  let clusters : Map[String, Array[String]] = Map::from_array([])
  for doc_id, _ in self.parent {
    let root = self.find(doc_id)
    match clusters.get(root) {
      Some(arr) => arr.push(doc_id)
      None => clusters.set(root, [doc_id])
    }
  }
  clusters
}

///|
/// Merges another disjoint set cluster into this one.
/// This allows parallel/distributed Union-Find computation where subsets of edges
/// are processed independently and then merged hierarchically.
pub fn DisjointSetCluster::merge(
  self : DisjointSetCluster,
  other : DisjointSetCluster,
) -> Unit {
  for x, _ in other.parent {
    let parent_x = other.find(x)
    self.union(x, parent_x)
  }
}

///|
/// Computes DisjointSetCluster using a divide-and-conquer strategy.
/// Splits edges into chunks, processes each chunk sequentially to construct
/// local disjoint set graphs, and merges them hierarchically.
///
/// NOTE: This function is a sequential simulation of the hierarchical merge model.
/// In a true distributed or multi-threaded runtime (e.g. MapReduce or C multi-threading),
/// the chunked edge sets are processed in parallel on different threads/cores/nodes, and
/// the final tree-reduction merge executes in O(log P) steps to aggregate sub-clusters.
pub fn hierarchical_merge_cluster(
  edges : Array[(String, String)],
  num_chunks : Int,
) -> DisjointSetCluster {
  if edges.length() == 0 {
    return DisjointSetCluster::new()
  }

  let chunks = if num_chunks < 1 { 1 } else { num_chunks }
  let chunk_size = (edges.length() + chunks - 1) / chunks
  let sub_clusters = Array::new(capacity=chunks)

  for w = 0; w < chunks; w = w + 1 {
    let start = w * chunk_size
    let end = if (w + 1) * chunk_size > edges.length() {
      edges.length()
    } else {
      (w + 1) * chunk_size
    }
    if start >= edges.length() {
      break
    }

    let cluster = DisjointSetCluster::new()
    for i = start; i < end; i = i + 1 {
      let (u, v) = edges[i]
      cluster.union(u, v)
    }
    sub_clusters.push(cluster)
  }

  // Hierarchical tree-reduction merge
  let mut step = 1
  while step < sub_clusters.length() {
    let mut i = 0
    while i + step < sub_clusters.length() {
      sub_clusters[i].merge(sub_clusters[i + step])
      i = i + step * 2
    }
    step = step * 2
  }

  if sub_clusters.length() > 0 {
    sub_clusters[0]
  } else {
    DisjointSetCluster::new()
  }
}
