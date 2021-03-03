---
title: "Prim's Minimum Spanning Tree"
date: 2020-06-12T00:56:05+02:00
toc: false
images:
tags:
  - Graphs
---

# Introduction

[prim's Algorithm](https://en.wikipedia.org/wiki/Prim%27s_algorithm) find minimum spanning tree for weighted undirected graph.

basically, Minimum spanning tree is sub-graph (in this case tree) that connect all vertices of weight graph. This requires that original graph is connected.

MST is useful for network distribution problems.

# The algorithm
From the wiki:

- Initialize a tree with a single vertex, chosen arbitrarily from the graph.
- Grow the tree by one edge: of the edges that connect the tree to vertices not yet in the tree, find the minimum-weight edge, and transfer it to the tree.
- Repeat step 2 (until all vertices are in the tree).

# Implementation

- As usual, adjacency list graph.

```python
class Graph:
    def __init__(self, V):
        self.V = V
        self.graph = [[] for i in range(V)]

    def connect(self, n1,n2, w):
        self.graph[n1].append((n2,w))
        self.graph[n2].append((n1,w))
```

- The tricky part is knowing the edge to add. I use `mstSet` as the temp sub-graph. This means the termination condition is  all vertices are in `mstSet`. probably, This is not the best implementation but it's good enough for this.

```python
            value = float('inf')
            for n1 in mstSet:
                for (n2,w) in self.graph[n1]:
                    if w < value and (not n2 in mstSet):
                        edge = (n1,n2,w)
                        value = w

          run = len(mstSet) != self.V
```
# Putting it all together
```python

import random

class Graph:
    def __init__(self, V):
        self.V = V
        self.graph = [[] for i in range(V)]

    def connect(self, n1,n2, w):
        self.graph[n1].append((n2,w))
        self.graph[n2].append((n1,w))


class Prim(Graph):
    def __init__(self,V):
        Graph.__init__(self,V)
        self.mst  = Graph(self.V)

        
    def MST(self):
        mstSet = []
        # initial random node
        start = random.randint(0, self.V-1)
        mstSet.append(start)
        print(f">> Starting at node {start}")
        total = 0
        run = True
        while run:
            # Get the edge and add the node to mstSet
            edge= ()
            
            value = float('inf')
            for n1 in mstSet:
                for (n2,w) in self.graph[n1]:
                    if w < value and (not n2 in mstSet):
                        edge = (n1,n2,w)
                        value = w
                        
            
            mstSet.append(edge[1])
            total += edge[2]
            print(f"edge={edge}")
            # connect the node 
            self.mst.connect(*edge)
            # check if all nodes are in the MST
            run = len(mstSet) != self.V
        print(f"total weight={total}")
        


def main():
    g = Prim(9)
    g.connect(0,1,4)
    g.connect(0,7,8)
    g.connect(1,7,11)
    g.connect(1,2,8)
    g.connect(7,8,7)
    g.connect(7,6,1)
    g.connect(2,8,2)
    g.connect(2,5,4)
    g.connect(2,3,7)
    g.connect(8,6,6)
    g.connect(6,5,2)
    g.connect(3,5,14)
    g.connect(3,4,9)
    g.connect(5,4,10)
    g.MST()

    for v in g.mst.graph:
        print(f"vertix={v}")

if __name__ == "__main__":
    main()

```
