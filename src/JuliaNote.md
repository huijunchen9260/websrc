# Note on Julia

## Table of Content

<!-- vim-markdown-toc GFM -->

* [Installation](#installation)
* [Julia Introduction](#julia-introduction)
* [Julia Tips](#julia-tips)
    * [Memory Allocations](#memory-allocations)

<!-- vim-markdown-toc -->


## Installation

- Julia Download page: [Stable release](https://julialang.org/downloads/)
- Julia Installation Instruction:
    - Windows: [Official Instruction](https://julialang.org/downloads/platform/#windows)
    - MacOS: [Official Instruction](https://julialang.org/downloads/platform/#macos)
- Jupyter Notebook / Jupyter Lab Installation Instruction: [Official Instruction](https://docs.jupyter.org/en/latest/install.html)
- Link Jupyter Notebook with Julia: [Video tutorial on Windows](https://www.youtube.com/watch?v=81DRruCIO34), [Video tutorial on MacOS](https://www.youtube.com/watch?v=oyx8M1yoboY)


## Julia Introduction

- 100 Seconds Intro by Fireship: [video](https://www.youtube.com/watch?v=JYs_94znYy0)

## Julia Tips

### Memory Allocations

Due to the nature of LLVM, memory allocation in Julia can be very expensive. Especially in dynamic programming, we usually a lot of arrays to store our data. Therefore, tracking where the memory is allocated can fast computation a lot.

- [Tracking memory allocations: JuliaNotes.jl](https://m3g.github.io/JuliaNotes.jl/stable/memory/)

;tags: Miscellaneous
