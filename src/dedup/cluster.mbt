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
/// Computes DisjointSetCluster in parallel using divide-and-conquer strategy.
/// Splits edges into chunks, processes them in parallel, and merges them hierarchically.
pub fn parallel_cluster(
  edges : Array[(String, String)],
  num_workers : Int,
) -> DisjointSetCluster {
  if edges.length() == 0 {
    return DisjointSetCluster::new()
  }

  let workers = if num_workers < 1 { 1 } else { num_workers }
  let chunk_size = (edges.length() + workers - 1) / workers
  let sub_clusters = Array::new(capacity=workers)

  for w = 0; w < workers; w = w + 1 {
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
