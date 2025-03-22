---
title: One line docker commands
author: Konrad Zdeb
date: '2025-03-19'
slug: one-line-docker
categories: 
    - efficiency
    - how-to
tags:
    - python
    - docker
    - shell
---


Building robust data science development environment takes time and it's probably one of those processes that is never fully finished. If you like to squeeze 100% from your tools you will be keen to tweak, introduce efficiencies and add gadgets to make coding and development experience more productive, pleasant and enjoyable. Starting with basics, such as configuring your Python development space to efficiency handle different versions of the language and packages you may progress to expanding your text editors with plugins to facilitate linting, code suggest, conveniently manipulate execution of unit tests and CI/CD workflow. The one thing that is constant is that set-up is constantly evolving. I have recently switched from vin to nvim and re-created a lot of my previous vim and VimL based configuration in Lua. Before that I didn't have much need to write Lua code. 

If you are experimenting and learning new things, you may be interested in convenient way of managing installation and removal of various system components. In general, I use Homebrew to manage the installation and removal of system componenets and that works surprisingly well. Howeber, I have also came across scenarios where installing components through homebrew fills like unnecessary step. 

# scenarios

# Solution

Examples provided below work on the same basis, the code and commands are executed within disposable Docker containers. The process of needing to install software on local machine is completely removed from the system

# Example

Let's say that you have a simple Python script, that makes use fo the leverages the [AST](https://docs.python.org/3/library/ast.html#module-ast) module. The AST module stands for Abstract Syntax Tree and is usually used in scenarios where you may want to manipulate Python code programmatically. A common scenario may be working a linter or a solution that receives Python script or Python arguments. More advanced use case of AST could involve metaprogramming where we may be willing to generate Python code programmatically.

Let's say that script we are working with has the following structure. The script doesn't do much, in effect it checks if the value `42` is interpreted as `ast.Num`. When you are dealing with Python syntax programmatically, you may be willing to break down expressions and see how different elements are vbeing interpreted. 



``` python
import ast
node = ast.parse("x = 42")
print(isinstance(node.body[0].value, ast.Num))
```

```
## True
```



I will store this script as `/tmp/check_ast.py`. Now to the key question. Let's say that you want to share your work quickly; a proper commons sense approach would be to define minimum requirements where you script is expected to work. What if for whatever reason you are not in position to require and users to confirm to minimum requirements, think of legacy system, or you want for you boss to have a look at something and you want minimum friction possible. Will this work in Python version x?


``` bash
for version in 2.7 3.5 3.6 3.7 3.8.0 3.9 3.10 3.11; do
    echo "Python ${version}:"
    docker run --rm -v /tmp/check_ast.py:/check_ast.py python:$version python /check_ast.py
done
```

```
## Python 2.7:
## True
## Python 3.5:
## True
## Python 3.6:
## True
## Python 3.7:
## True
## Python 3.8.0:
## True
## Python 3.9:
## True
## Python 3.10:
## True
## Python 3.11:
## True
```

## Other interesting cases

In R's `tidyverse` ecosystem offers very pleasant way of previewing data. Let's say that you are not R user but would like to see how this works


``` bash
docker run --rm r-base R -e "install.packages('dplyr', verbose=FALSE); dplyr::glimpse(mtcars)"
```


``` bash
printf "Name,DOB,Value\n
Alice,1992-05-14,100\n
Bob,1988-09-22,200\n
Charlie,1995-07-30,150\n
David,1990-12-11,175\n
Eve,1985-03-05,300\n" > /tmp/sample_data.csv
```

### Julia


``` bash
docker run --rm -v /tmp/sample_data.csv:/data.csv julia julia -e 'import Pkg; Pkg.add("DataFrames"); Pkg.add("CSV"); using CSV, DataFrames; df = CSV.read("/data.csv", DataFrame); println(df)'
```

```
##   Installing known registries into `~/.julia`
##     Updating registry at `~/.julia/registries/General.toml`
##    Resolving package versions...
##    Installed DataAPI ───────────────────── v1.16.0
##    Installed Crayons ───────────────────── v4.1.1
##    Installed SentinelArrays ────────────── v1.4.8
##    Installed PooledArrays ──────────────── v1.4.3
##    Installed Tables ────────────────────── v1.12.0
##    Installed TableTraits ───────────────── v1.0.1
##    Installed Preferences ───────────────── v1.4.3
##    Installed PrettyTables ──────────────── v2.4.0
##    Installed DataValueInterfaces ───────── v1.0.0
##    Installed IteratorInterfaceExtensions ─ v1.0.0
##    Installed InvertedIndices ───────────── v1.3.1
##    Installed OrderedCollections ────────── v1.8.0
##    Installed LaTeXStrings ──────────────── v1.4.0
##    Installed InlineStrings ─────────────── v1.4.3
##    Installed PrecompileTools ───────────── v1.2.1
##    Installed DataFrames ────────────────── v1.7.0
##    Installed Reexport ──────────────────── v1.2.2
##    Installed Missings ──────────────────── v1.2.0
##    Installed Compat ────────────────────── v4.16.0
##    Installed StringManipulation ────────── v0.4.1
##    Installed SortingAlgorithms ─────────── v1.2.1
##    Installed DataStructures ────────────── v0.18.22
##     Updating `~/.julia/environments/v1.10/Project.toml`
##   [a93c6f00] + DataFrames v1.7.0
##     Updating `~/.julia/environments/v1.10/Manifest.toml`
##   [34da2185] + Compat v4.16.0
##   [a8cc5b0e] + Crayons v4.1.1
##   [9a962f9c] + DataAPI v1.16.0
##   [a93c6f00] + DataFrames v1.7.0
##   [864edb3b] + DataStructures v0.18.22
##   [e2d170a0] + DataValueInterfaces v1.0.0
##   [842dd82b] + InlineStrings v1.4.3
##   [41ab1584] + InvertedIndices v1.3.1
##   [82899510] + IteratorInterfaceExtensions v1.0.0
##   [b964fa9f] + LaTeXStrings v1.4.0
##   [e1d29d7a] + Missings v1.2.0
##   [bac558e1] + OrderedCollections v1.8.0
##   [2dfb63ee] + PooledArrays v1.4.3
##   [aea7be01] + PrecompileTools v1.2.1
##   [21216c6a] + Preferences v1.4.3
##   [08abe8d2] + PrettyTables v2.4.0
##   [189a3867] + Reexport v1.2.2
##   [91c51154] + SentinelArrays v1.4.8
##   [a2af1166] + SortingAlgorithms v1.2.1
##   [892a3eda] + StringManipulation v0.4.1
##   [3783bdb8] + TableTraits v1.0.1
##   [bd369af6] + Tables v1.12.0
##   [56f22d72] + Artifacts
##   [2a0f44e3] + Base64
##   [ade2ca70] + Dates
##   [9fa8497b] + Future
##   [b77e0a4c] + InteractiveUtils
##   [8f399da3] + Libdl
##   [37e2e46d] + LinearAlgebra
##   [d6f4376e] + Markdown
##   [de0858da] + Printf
##   [9a3f8284] + Random
##   [ea8e919c] + SHA v0.7.0
##   [9e88b42a] + Serialization
##   [2f01184e] + SparseArrays v1.10.0
##   [10745b16] + Statistics v1.10.0
##   [fa267f1f] + TOML v1.0.3
##   [cf7118a7] + UUIDs
##   [4ec0a83e] + Unicode
##   [e66e0078] + CompilerSupportLibraries_jll v1.1.1+0
##   [4536629a] + OpenBLAS_jll v0.3.23+4
##   [bea87d4a] + SuiteSparse_jll v7.2.1+1
##   [8e850b90] + libblastrampoline_jll v5.8.0+1
## Precompiling project...
##   ✓ IteratorInterfaceExtensions
##   ✓ Reexport
##   ✓ LaTeXStrings
##   ✓ DataValueInterfaces
##   ✓ InvertedIndices
##   ✓ DataAPI
##   ✓ CompilerSupportLibraries_jll
##   ✓ Compat
##   ✓ OrderedCollections
##   ✓ InlineStrings
##   ✓ Preferences
##   ✓ TableTraits
##   ✓ Statistics
##   ✓ Missings
##   ✓ PooledArrays
##   ✓ Compat → CompatLinearAlgebraExt
##   ✓ Crayons
##   ✓ PrecompileTools
##   ✓ SentinelArrays
##   ✓ Tables
##   ✓ DataStructures
##   ✓ StringManipulation
##   ✓ SortingAlgorithms
##   ✓ PrettyTables
##   ✓ DataFrames
##   25 dependencies successfully precompiled in 42 seconds. 2 already precompiled.
##    Resolving package versions...
##    Installed CodecZlib ────────── v0.7.8
##    Installed Parsers ──────────── v2.8.1
##    Installed TranscodingStreams ─ v0.11.3
##    Installed WeakRefStrings ───── v1.4.2
##    Installed WorkerUtilities ──── v1.6.1
##    Installed FilePathsBase ────── v0.9.24
##    Installed CSV ──────────────── v0.10.15
##     Updating `~/.julia/environments/v1.10/Project.toml`
##   [336ed68f] + CSV v0.10.15
##     Updating `~/.julia/environments/v1.10/Manifest.toml`
##   [336ed68f] + CSV v0.10.15
##   [944b1d66] + CodecZlib v0.7.8
##   [48062228] + FilePathsBase v0.9.24
##   [69de0a69] + Parsers v2.8.1
##   [3bb67fe8] + TranscodingStreams v0.11.3
##   [ea10d353] + WeakRefStrings v1.4.2
##   [76eceee3] + WorkerUtilities v1.6.1
##   [a63ad114] + Mmap
##   [83775a58] + Zlib_jll v1.2.13+1
## Precompiling project...
##   ✓ WorkerUtilities
##   ✓ TranscodingStreams
##   ✓ FilePathsBase
##   ✓ CodecZlib
##   ✓ FilePathsBase → FilePathsBaseMmapExt
##   ✓ Parsers
##   ✓ InlineStrings → ParsersExt
##   ✓ WeakRefStrings
##   ✓ CSV
##   9 dependencies successfully precompiled in 23 seconds. 28 already precompiled.
## 5×3 DataFrame
##  Row │ Name     DOB         Value
##      │ String7  Date        Int64
## ─────┼────────────────────────────
##    1 │ Alice    1992-05-14    100
##    2 │ Bob      1988-09-22    200
##    3 │ Charlie  1995-07-30    150
##    4 │ David    1990-12-11    175
##    5 │ Eve      1985-03-05    300
```

# Summary

Docker is extremely efficient in working as a solution to run one line commands
