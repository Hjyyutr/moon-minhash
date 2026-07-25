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
