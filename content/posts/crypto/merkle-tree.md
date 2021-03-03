---
title: "Merkle Tree"
date: 2020-05-29T23:04:23+02:00
toc: false
images:
tags:
  - crypto
---

[Merkle tree](https://en.wikipedia.org/wiki/Merkle_tree) is hash tree (usually binary tree) where each node is hash function of children nodes.
i used binary tree with sha256 from `hashlib`.

# Building the tree
i choose to start from the leafs and build up the tree bottom-to-top. `_buildTree` does that by the recursively building parent nodes. for uniformity, i chose to add padding node to the tree (with empty hash string). this way the nodes are always even number all the way to the root node. this means unneeded nodes but easier logic. I didn't put much thought about the upper limit for the number of dummy nodes.

`_buildTree` will be called `log2(N)` where N is number of original leafs. and each call loops over `log2(n)`
this means `log2(N/2) + Log2(N/4) + log2(N/8) ... + log(1)` loops.

for each two nodes, hash is calculated with concatenating left and right hashes in that order.

```python
    def buildTree(self, data):
        nodes = [MerkleNode(self.getHash(d)) for d in data]
        self.root = self._buildTree(nodes,1)
    
    def _buildTree(self, nodes,level):
        if len(nodes) == 1:
            return nodes[0]
        else:
            new_level =[]
            # the extra padding node here!
            (depth, isOdd) = divmod(len(nodes),2)
            if (isOdd):
                nodes.append(MerkleNode(''))
                depth = depth + 1

            for i in range(depth):
                left = nodes[2*i]
                right = nodes[2*i+1]
                children_data = (left.data  + right.data)
                node = MerkleNode(self.getHash(children_data)) 
                node.left = left
                node.right = right
                left.parent = node
                right.parent = node
                new_level.append(node)
            return self._buildTree(new_level,level +1)

```

# Getting Trail
The second part of Merkle tree, is that multiple parties can calculate *trail* hashes to leaf nodes and we can verify that trail with leaf hash.

for easy implementation,i did the trail traversal in two steps
- Get the path from root to leaf (if it's there)
- if found, iterate on the path and get the sibling child of each node.

if hash is not found, `getTrail` returns `[]`. if found it returns the path as `list` of `[root, (node,direction), (node,direction)...]`

There are several improvements that can be done here:
- change the interface for `_getTrail` and make it pure instead of using `self.found_trail`
- Traverse the tree once and terminate afterwards
  
```python
 def getTrail(self,data):
        self.trail = []
        self.found_trail = []
        self._getTrail(self.root,0,data)

        # Trail not found at self.found_trail
        if len(self.found_trail) ==0:
            return list()
        # Trail found. from parent(root), get the sibilings
        hash_trail = [self.root]
        for idx in range(len(self.found_trail)-1):
            if (self.found_trail[idx].left.data == self.found_trail[idx+1].data):
                hash_trail.append((self.found_trail[idx].right,'left'))
            elif (self.found_trail[idx].right.data == self.found_trail[idx+1].data):
                hash_trail.append((self.found_trail[idx].left,'right'))
        return hash_trail
        
    def _getTrail(self,node, level,data):
        self.trail.append(node)
        if(node.left ==None and node.right == None and data == node.data):
            self.found_trail = list(self.trail)
        if node.left != None:
            self._getTrail(node.left, level+1,data)
        if node.right != None:
            self._getTrail(node.right,level+1,data)
        self.trail.pop()
```
# Verify trail and hash
once we have a trail, we can reverse the trail and calculate the hashes every two nodes all the way up to the root.
I am assuming the trail is given with first node as root then tuples of `(node, direction)` same as calculated with `getTrail`

```python
    def verifyTrail(self,trail, data):
        hash = None
        root = trail[0]
        hash = data
        new_trail = list(trail[1:])
        new_trail.reverse()
        for (node,direction) in new_trail:
            if direction == 'left':
                term =  hash + node.data
            else:
                term = node.data + hash
            hash = self.getHash(term)
        return hash == root.data
```

# All together
``` python

import hashlib
import string

class MerkleNode():
    def __init__(self, data):
        self.right = None
        self.left  = None
        self.parent = None
        self.data  = data

class MerkleTree():
    def __init__(self):
        self.root = None
    
    def getHash(self,data):
        return hashlib.sha256(data.encode()).hexdigest()
        
    def buildTree(self, data):
        nodes = [MerkleNode(self.getHash(d)) for d in data]
        self.root = self._buildTree(nodes,1)
    
    def _buildTree(self, nodes,level):
        if len(nodes) == 1:
            return nodes[0]
        else:
            new_level =[]
            (depth, isOdd) = divmod(len(nodes),2)
            if (isOdd):
                nodes.append(MerkleNode(''))
                depth = depth + 1

            for i in range(depth):
                left = nodes[2*i]
                right = nodes[2*i+1]
                children_data = (left.data  + right.data)
                node = MerkleNode(self.getHash(children_data)) 
                node.left = left
                node.right = right
                left.parent = node
                right.parent = node
                new_level.append(node)
            return self._buildTree(new_level,level +1)

    def printTree(self):
        self._printTree(self.root,0)
        
    def _printTree(self,node, level):
        print(f"{level}: {node.data}")
        if node.left != None:
            self._printTree(node.left, level+1)
        if node.right != None:
            self._printTree(node.right,level+1)

    def getRoot(self):
        return self.root.data

    def getTrail(self,data):
        self.trail = []
        self.found_trail = []
        self._getTrail(self.root,0,data)

        # Trail not found at self.found_trail
        if len(self.found_trail) ==0:
            return list()
        # Trail found. from parent(root), get the sibilings
        hash_trail = [self.root]
        for idx in range(len(self.found_trail)-1):
            if (self.found_trail[idx].left.data == self.found_trail[idx+1].data):
                hash_trail.append((self.found_trail[idx].right,'left'))
            elif (self.found_trail[idx].right.data == self.found_trail[idx+1].data):
                hash_trail.append((self.found_trail[idx].left,'right'))
        return hash_trail
        
    def _getTrail(self,node, level,data):
        self.trail.append(node)
        if(node.left ==None and node.right == None and data == node.data):
            self.found_trail = list(self.trail)
        if node.left != None:
            self._getTrail(node.left, level+1,data)
        if node.right != None:
            self._getTrail(node.right,level+1,data)
        
        self.trail.pop()

    def verifyTrail(self,trail, data):
        hash = None
        root = trail[0]
        hash = data
        new_trail = list(trail[1:])
        new_trail.reverse()
        for (node,direction) in new_trail:
            if direction == 'left':
                term =  hash + node.data
            else:
                term = node.data + hash
            hash = self.getHash(term)
        return hash == root.data

def main():
    file = "01234567" 
    data = list(file)

    tree = MerkleTree()
    tree.buildTree(data)

    print(f"Root: {tree.getRoot()}")

    tree.printTree()

    trail = tree.getTrail(tree.getHash("3"))
    ret = tree.verifyTrail(trail,tree.getHash("3"))
    print(f"{ret}")

if __name__ == "__main__":
    main()

```