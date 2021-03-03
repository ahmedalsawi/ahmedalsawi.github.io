---
title: "Conway Game of Life"
date: 2020-05-23T15:23:40+02:00
toc: false
images:
tags:
  
  - algorithms
---

Conway's Game of Life is zero-player game introduced by  mathematician John Horton Conway  in 1970. it has it's own [wiki](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) and all.

The rules are simple, you start with a grid of cells with initial state of either living or dead. and cells interact with neighbors to define the next generation of cells.

- Any live cell with fewer than two live neighbors dies, as if by under-population.
- Any live cell with two or three live neighbors lives on to the next generation.
- Any live cell with more than three live neighbors dies, as if by overpopulation.
- Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction

# Implementation
I did quick with python at [repo](https://github.com/ahmedalsawi/conway-game). It's using numpy and scipy for matrix operations. and matplotlib for plotting and animation.

![Example image](/conway01.png)

# Animation
matplotlib is new to me, so it took me some time to understand the basic building blocks. but what i want to highlight below is `FuncAnimation`


```python
    def generations(self):
        for g in range (self.G):
            yield self.step()


    def run(self):
        fig, ax = plt.subplots()
        mat = ax.matshow(self.grid)   
        ani = animation.FuncAnimation(fig, mat.set_data, self.generations, interval=500, repeat=False)
        plt.show()
```

the [docs](https://matplotlib.org/3.2.1/api/_as_gen/matplotlib.animation.FuncAnimation.html) says

> fig: Figure
> The figure object that is used to get draw, resize, and any other needed events.
> 
> func: callable
> The function to call at each frame. The first argument will be the next value in frames. Any additional positional arguments can be > supplied via the fargs parameter.
> 
> frames: iterable, int, generator function, or None, optional
> If an iterable, then simply use the values provided. If the iterable has a length, it will override the save_count kwarg.
> 

So, the second parameter is `callable`, in this case i am passing `mat.set_data` so, it will be called by matplolib to update frames.
but the most important part is that third parameter is `iterable` or `int` or `generator function`. and this parameter will be passed to the callable in parameter 2.

```python
def func(frame, *fargs) 
```

which effectively is doing the following considering the generator will run `G` generations before stopping.

```python
def mat.set_data(this.grid)
```

# gotcha
well, the game is straightforward to write but there was that bugged me little. calculating the number of neighbors living cells.
i initially implemented by manually counting using (i,j) index and it worked but it was ugly with boundary cells, if conditions and for loops. but i found `convolve2d` from `scipy`. it's interesting because using the right kernel, i can count the neighbors for all cells with one line. more details about convolution [wiki](https://en.wikipedia.org/wiki/Kernel_(image_processing))

```python
        W = np.array([[1, 1, 1],
              [1, 0, 1],
              [1, 1, 1]])
        self.neighbour = signal.convolve2d(self.grid, W, 'same')
```

