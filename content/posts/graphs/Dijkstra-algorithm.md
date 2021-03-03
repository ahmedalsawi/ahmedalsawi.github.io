---
title: "Dijkstra Algorithm"
date: 2020-06-10T22:04:46+02:00
toc: false
images:
tags:
  - Graphs
---

# Introduction

[Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm) says it is an algorithm for finding the shortest paths between nodes in a graph. 

Dijkstra is big deal because it's used to find the best way (based on weight function) between points A and B on a graph. It works well on graphs with non-negative edges.

Considering the instance of the problem where A and B is connected and graph and required to calculate minimum cost for that path.

# Algorithm
I used the same exact algorithm as wiki page.

- Mark all nodes unvisited. Create a set of all the unvisited nodes called the unvisited set.
Assign to every node a tentative distance value: set it to zero for our initial node and to infinity for all other nodes. Set the initial node as current.[14]
- For the current node, consider all of its unvisited neighbours and calculate their tentative distances through the current node. Compare the newly calculated tentative distance to the current assigned value and assign the smaller one. For example, if the current node A is marked with a distance of 6, and the edge connecting it with a neighbour B has length 2, then the distance to B through A will be 6 + 2 = 8. If B was previously marked with a distance greater than 8 then change it to 8. Otherwise, the current value will be kept.
- When we are done considering all of the unvisited neighbours of the current node, mark the current node as visited and remove it from the unvisited set. A visited node will never be checked again.
- If the destination node has been marked visited (when planning a route between two specific nodes) or if the smallest tentative distance among the nodes in the unvisited set is infinity (when planning a complete traversal; occurs when there is no connection between the initial node and remaining unvisited nodes), then stop. The algorithm has finished.
- Otherwise, select the unvisited node that is marked with the smallest tentative distance, set it as the new "current node", and go back to step 3.


There is variant where it's need to calculate minimum distance to all nodes. It's essentially the same steps but the condition for search termination will be that all nodes are visited instead of the destination node.

# Implementation
- I used adjacency list to represent the graph.

```python
    def __init__(self, V):
        self.V = V
        self.graph = [[] for i in range(V)]

    def connect(self, n1,n2, w):
        self.graph[n1].append((n2,w))
        self.graph[n2].append((n1,w))
```
- The algorithm says *inf* as initial distance to all nodes. I initially used -1 to represent inf but i complicated the comparisons. but i found out python have `float('inf')` which works fine in arithmetic operations.

- The shortest path between two points and shortest path spanning tree(shortest path to all nodes) is the same. the only difference is the termination condition. For two points, i just need to check the destination node was visited.

```python

            # check for algorithm termination and calculate the new "current"
            if n2 is None:
                run =  (True in unvisited) 
            else:
                run = (unvisited[n2] == True)
```

# Putting it all together
```python

class Dijkstra:
    """
    Implementation based on algorithm in 
    https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
    """
    def __init__(self, V):
        self.V = V
        self.graph = [[] for i in range(V)]

    def connect(self, n1,n2, w):
        self.graph[n1].append((n2,w))
        self.graph[n2].append((n1,w))

    def shortestPath(self, n1, n2=None):
        unvisited = [True] * self.V

        distance = [ float('inf') ] * self.V
        distance[n1] = 0

        current = n1

        run  = True
        while run:
            #print(f">>>> current={current}")
            # iterate the neighbours
            for neighbour in self.graph[current]:
                (n,w) = neighbour

                if unvisited[n]:
                    # Loop over neighbours
                    #print(f"    >>>> neighbour={n} weight={w}")
                    new_dist = distance[current] + w

                    if  new_dist < distance[n]:
                        #print(f"        >>>> updated distance {new_dist}")
                        distance[n] = new_dist
                    
            unvisited[current] = False

            # check for algorithm termination and calculate the new "current"
            if n2 is None:
                run =  (True in unvisited) 
            else:
                run = (unvisited[n2] == True)
            
            value = float('inf')
            for v in range(self.V):
                if distance[v] < value and unvisited[v] == True:
                    value = distance[v]
                    n_current = v
            
            current = n_current

        print(distance)
            

def main():
    g = Dijkstra(9)
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
    g.shortestPath(0,7)
    
    g.shortestPath(0)
    g.shortestPath(1)
if __name__ == "__main__":
    main()
```
