---
title: "Sudoku SAT Solution"
date: 2020-05-24T20:49:37+02:00
toc: false
images:
tags:
  - Algorithms
---

This one is about two things Sudoku and SAT (obviously!). Let's start with definitions:

# Sudoku
Sudoku is a puzzle with the objective to fill 9x9 grid with numbers between 1 and 9. There are few rules
- All cells must have one number between 1 and 9
- Rows and columns must contain unique numbers 1 to 9 (no repeated digits)
- each 3x3 sub-grid (AKA box) must contain unique numbers 1 to 9 (to repeated digits)

Check out the [wiki](https://en.wikipedia.org/wiki/Sudoku)

it usually starts with an initial combination that should result into one unique solution. this is example from the wiki page.
![Example image](/sudoku-wiki.png)

# SAT Problem
`Boolean satisfiability problem` is an important computer science NP-complete problem. It has many applications in circuit design and formal proves. for now, I found the best resource is wiki [SAT wiki](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem) but there other books and lectures all over the place.

basically, SAT answers one question. For bool function `f(x1,x2, ... ,xn)`, is there a combination of values for `x1, x2, .. xn` that could make `f` true.

if it finds one, it will return it. otherwise, `f` is UNSAT.

One way to represent SAT input data set is [CNF](https://en.wikipedia.org/wiki/Conjunctive_normal_form).

> In Boolean logic, a formula is in conjunctive normal form (CNF) or clausal normal form if it is a conjunction of one or more clauses, where a clause is a disjunction of literals; otherwise put, it is an AND of ORs. As a canonical normal form, it is useful in automated theorem proving and circuit theory.

it is basically  POS (product of sum).

for example, function `(x1 | x2) & (x2 | ~x3)` with 3 variables x1, x2 ,x3 can be used for represented

```
1 2
2 -3 
```

this format is called [DIMACS](https://people.sc.fsu.edu/~jburkardt/data/cnf/cnf.html) and used with many SAT solvers. one famous solver is [minisat](http://minisat.se/) which reads DIMACS directly.

for this post, I used [pycosat](https://github.com/ContinuumIO/pycosat) with simple API for simple problem like one we have here.

```
>>> import pycosat
>>> cnf = [[1, -5, 4], [-1, 5, 3, 4], [-3, -4]]
>>> pycosat.solve(cnf)
[1, -2, -3, -4, 5]
```

# Implementation
At this point, the biggest problem is how to translate sudoku into CNF.

The most useful resource was [lecture](http://cse.unl.edu/~choueiry/S17-235H/files/SATslides02.pdf), it has instructions how to map sudoku rules into CNF. Combined with [instructions](http://www.cs.qub.ac.uk/~I.Spence/SuDoku/SuDoku.html), i could write the CNF generator for  sudoku and append the initial state.

One important aspect here is that we need to translate the sudoku grid which includes i, j and value to linear variable list that CNF needs. `ijk_idx` is used for that and it's used heavily for CNF generator.

```python
N=10
def ijk_idx(i,j,k):
    return (i * N * N + j * N + k)
```

the full source can be found on github, but i am including 9x9 cells rule. i added comments for more clarification.

```python
    for i in range(1,10):
        for j in range(1,10): # loop over cells
            # for all values 1-9  that could at this cell. 
            #for example for row 1 col 1, the cl will be
            # [111 112 113 ... 119]
            cl = [ijk_idx(i,j,k) for k in range(1,10)] 
            cnf.append(cl)

    for i in range(1,10):
        for j in range(1,10):
            # for cell you can have only one value
            # if it contains 1, it shouldn't contain 2 , 3, 4... 9
            # if it contains 2, it shouldn't contain 3, 4, ...9
            for x in range(1,9):
                for y in range(x+1,10):
                    cl = [-1*ijk_idx(i,j,x), -1*ijk_idx(i,j,y)]
                    cnf.append(cl)
```

I used numpy matric as sudoku grid for easier indexing and printing. this is grid after initial state.

```
Sudoku After initialization
===========================
[[0. 0. 0. 0. 0. 0. 0. 0. 0.]
 [0. 8. 9. 4. 1. 0. 0. 0. 0.]
 [0. 0. 6. 7. 0. 0. 1. 9. 3.]
 [2. 0. 0. 0. 0. 0. 7. 0. 0.]
 [3. 4. 0. 6. 0. 0. 0. 1. 0.]
 [0. 0. 0. 9. 0. 0. 0. 0. 5.]
 [0. 0. 0. 0. 2. 0. 0. 5. 0.]
 [6. 5. 0. 0. 4. 0. 0. 2. 0.]
 [7. 3. 0. 1. 0. 0. 0. 0. 0.]]
 ```

And after solution

 ```
Sudoku After Solving
===========================
[[1. 7. 3. 2. 6. 9. 5. 8. 4.]
 [5. 8. 9. 4. 1. 3. 6. 7. 2.]
 [4. 2. 6. 7. 5. 8. 1. 9. 3.]
 [2. 9. 1. 5. 8. 4. 7. 3. 6.]
 [3. 4. 5. 6. 7. 2. 8. 1. 9.]
 [8. 6. 7. 9. 3. 1. 2. 4. 5.]
 [9. 1. 4. 8. 2. 6. 3. 5. 7.]
 [6. 5. 8. 3. 4. 7. 9. 2. 1.]
 [7. 3. 2. 1. 9. 5. 4. 6. 8.]]
 ```