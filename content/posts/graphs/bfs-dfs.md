---
title: "Breadth-first and Depth-first Graph Searches"
date: 2020-06-12T19:04:24+02:00
toc: false
images:
tags:
  - Graphs
---

# Introduction
DFS and BFS  are probably first topic to do when doing anything related to graphs. I started with things like Dijkstra and prim which could be extension of DFS and BFS.

DFS and BFS can be used for several application like shortest path and detecting cycles and connected components.

# Breadth first search
[wiki](https://en.wikipedia.org/wiki/Breadth-first_search) says that BFS visits the nodes of a graph by visiting the neighbour nodes first then move to the next level of neighbours.

For implementation, a queue can be used to push the nodes being visited. and as long that q is not empty the traversal will keeping going until no more nodes to enqueue or dequeue.



```python
    def BFS(self,start):
        # init queue and visited
        q = []
        visited = [False] * self.V
        # Added start node to queue and mark it visited
        q.append(start)
        visited[start] = True

        while len(q) !=0:
            current = q.pop(0)
            print(f"BFS Node {current}")
            for (n,w) in self.graph[current]:
                if visited[n] == False and (not n in q): # the second condition 
                    visited[n] = True
                    q.append(n)
```

# Depth first search
[wiki](https://en.wikipedia.org/wiki/Depth-first_search) says that DFS visits nodes be going down in the graph until there is no reachable adjacent nodes. Then it backtracks to parent node and start iterating adjacent from there.

Stack is used to store nodes in the path from root to current node. Again, visiting means printing the correct node at correct time.

```python
    def DFS(self,start):
        # init stack and visited
        s = []
        visited = [False] * self.V

        s.append(start)
        
        while len(s) != 0:
            v = s.pop()
            if visited[v] == False:
                visited[v] = True
                print(f"DFS Node = {v}")
                for (n2,w) in self.graph[v]:
                    s.append(n2)

```

# Putting it all together
```python
class Graph:
    def BFS(self,start):

        q = []
        visited = [False] * self.V

        q.append(start)
        
        while len(q) !=0:
            current = q.pop(0)
            visited[current] = True
            print(f"{current}")
            for (n,w) in self.graph[current]:
                if visited[n] == False and (not n in q):
                    q.append(n)
    
    def getVertix(self,n,s,visitied):
        for (n2,w) in self.graph[n]:
            if (visitied[n2] == False):
                return n2
        return None

    def DFS(self,start):

        s = []
        visited = [False] * self.V

        s.append(start)
        visited[start] = True
        print(f"DFS Node = {start}")

        while len(s) != 0:
            adjVertix = self.getVertix(s[-1],s,visited)
            print(adjVertix)
            if adjVertix is None:
                s.pop()
            else:
                visited[adjVertix] = True
                print(f"DFS Node = {adjVertix}")
                s.append(adjVertix)




class UndirectedGraph(Graph):
    def __init__(self, V):
        self.V = V
        self.graph = [[] for i in range(V)]

    def connect(self, n1,n2, w):
        self.graph[n1].append((n2,w))
        self.graph[n2].append((n1,w))

class DirectedGraph(Graph):
    def __init__(self, V):
        self.V = V
        self.graph = [[] for i in range(V)]

    def connect(self, n1,n2, w):
        self.graph[n1].append((n2,w))



        
def main():
    g = DirectedGraph(4)
    g.connect(1,2,0)
    g.connect(0,2,0)
    g.connect(0,1,0)
    g.connect(2,0,0)
    g.connect(2,3,0)
    g.connect(3,3,0)
    print('>>>>>>>>> BFS')
    g.BFS(2)
    print('>>>>>>>>> DFS')
    g.DFS(2)

    print('===================')
    g1 = UndirectedGraph(6)
    g1.connect(0,1,0)
    g1.connect(0,2,0)
    g1.connect(1,4,0)
    g1.connect(1,3,0)
    g1.connect(2,4,0)
    g1.connect(3,4,0)
    g1.connect(3,5,0)
    g1.connect(4,5,0)
    print('BFS')
    g1.BFS(0)
    print('DFS')
    g1.DFS(0)
if __name__ == "__main__":
    main()

```