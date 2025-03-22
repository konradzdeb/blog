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


Setting up a robust data science development environment takes time, and it's a process that’s rarely ever finished. If you’re the type who likes to get the most out of your tools, you’ll likely enjoy tweaking, optimising, and layering your workspace with productivity enhancements. That might mean refining your Python setup to easily manage multiple language versions and dependencies, or expanding your text editor with plugins for linting, code suggestions, unit test execution, and CI/CD integration.

The only constant is that your environment is always evolving. I recently moved from `vim` to `nvim` and rewrote much of my VimL-based configuration in Lua—something I’d never touched before. If you’re experimenting, learning, and building in parallel, having a clean way to isolate and test changes becomes invaluable.

## Managing tools without installing them

In most cases, I use Homebrew to manage system components on my machine, and it works well. But there are situations where installing something locally feels excessive—especially if I only need it temporarily.

## Solution

Examples provided below work on the same basis, the code and commands are executed within disposable Docker containers. The process of needing to install software on local machine is completely removed from the system

## Example: Python AST across versions

Suppose you’re working with a simple Python script using the `ast` module, which allows you to parse and analyse Python code as an abstract syntax tree. This is commonly used in tools like linters or code formatters, but also in more advanced metaprogramming scenarios.

Here’s a minimal script that parses the assignment `x = 42` and checks whether the literal `42` is represented using `ast.Num`.

Intuitively, we might expect this to return `True`—after all, `42` is a number, and `ast.Num` seems appropriate. But that's not always the case.

Now we run it across various Python versions using Docker.


``` python
import ast
print(type(ast.parse("x = 42").body[0].value) is ast.Num)
```




I will store this script as `/tmp/check_ast.py`. Using the docker one liner, I will execute the script in multiple version of Python.


``` bash
for version in 2.7 3.5 3.6 3.7 3.8 3.9 3.10 3.11 3.12 3.13; do
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
## Python 3.8:
## False
## Python 3.9:
## False
## Python 3.10:
## False
## Python 3.11:
## False
## Python 3.12:
## False
## /check_ast.py:2: DeprecationWarning: ast.Num is deprecated and will be removed in Python 3.14; use ast.Constant instead
##   print(type(ast.parse("x = 42").body[0].value) is ast.Num)
## Python 3.13:
## False
## /check_ast.py:2: DeprecationWarning: ast.Num is deprecated and will be removed in Python 3.14; use ast.Constant instead
##   print(type(ast.parse("x = 42").body[0].value) is ast.Num)
```

You’ll notice the results vary. Some versions return `True`, others return `False`. This reflects the evolution of the `ast` module. Although `ast.Constant` was introduced in Python 3.8 to unify literals like numbers, strings, and constants under one node type, `ast.Num`, `ast.Str`, and related nodes were not immediately retired. In fact, `ast.parse()` continued to return `ast.Num` in Python 3.8, 3.9, and even 3.10.0, to preserve compatibility.

As a result, `isinstance(..., ast.Num)` still returned `True` in those versions. The complete shift to `ast.Constant` occurred in Python 3.11, where `ast.parse()` finally stopped emitting the older nodes. This is a good example of how language-level changes may be rolled out gradually, and why it’s useful to test behaviour directly—rather than rely on changelog summaries alone.


## Other interesting uses

For quick evaluation it is possible to direcltly jump into ipython console. I find this partilculary useful if I want to check running some code interactively in a specific version of Python.


``` bash
docker run -it --rm python:3.8 bash -c "pip install ipython && ipython"
```

The other trick that I find useful in those scenarios is to install packages while in Python interactive session by calling `subprocess`, this can be easily achieved via running `subprocess` command pointing to `pip` as shown below:


``` python
import subprocess
import sys
subprocess.run([sys.executable, "-m", "pip", "install", "pandas"], check=True)
import pandas as pd
print(pd.__version__)
```
One line docker commands can be also usefully used to handle external data. I was recently hearing alot about how pleasant is to work with Julia. Let's say I would like to condduct a simple test and see how efficient is Julia in handling CSV files and berforming basic operations. Using the file created below.


``` bash
printf "Name,DOB,Value\n
Alice,1992-05-14,100\n
Bob,1988-09-22,200\n
Charlie,1995-07-30,150\n
David,1990-12-11,175\n
Eve,1985-03-05,300\n" > /tmp/sample_data.csv
```

I would be able to simply load it and analyse the outputs.


``` bash
docker run --rm -v /tmp/sample_data.csv:/data.csv julia julia \
-e 'import Pkg; Pkg.add("DataFrames"); Pkg.add("CSV"); using CSV, DataFrames; df = CSV.read("/data.csv", DataFrame); println(df)'
```

```
##   Installing known registries into `~/.julia`
##     Updating registry at `~/.julia/registries/General.toml`
##    Resolving package versions...
##    Installed Crayons ───────────────────── v4.1.1
##    Installed PooledArrays ──────────────── v1.4.3
##    Installed SentinelArrays ────────────── v1.4.8
##    Installed TableTraits ───────────────── v1.0.1
##    Installed Tables ────────────────────── v1.12.0
##    Installed DataAPI ───────────────────── v1.16.0
##    Installed Preferences ───────────────── v1.4.3
##    Installed PrettyTables ──────────────── v2.4.0
##    Installed DataValueInterfaces ───────── v1.0.0
##    Installed IteratorInterfaceExtensions ─ v1.0.0
##    Installed InvertedIndices ───────────── v1.3.1
##    Installed LaTeXStrings ──────────────── v1.4.0
##    Installed InlineStrings ─────────────── v1.4.3
##    Installed OrderedCollections ────────── v1.8.0
##    Installed PrecompileTools ───────────── v1.2.1
##    Installed DataFrames ────────────────── v1.7.0
##    Installed Reexport ──────────────────── v1.2.2
##    Installed Missings ──────────────────── v1.2.0
##    Installed Compat ────────────────────── v4.16.0
##    Installed StringManipulation ────────── v0.4.1
##    Installed DataStructures ────────────── v0.18.22
##    Installed SortingAlgorithms ─────────── v1.2.1
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
##   ✓ DataValueInterfaces
##   ✓ Reexport
##   ✓ DataAPI
##   ✓ LaTeXStrings
##   ✓ InvertedIndices
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
##   25 dependencies successfully precompiled in 43 seconds. 2 already precompiled.
##    Resolving package versions...
##    Installed WorkerUtilities ──── v1.6.1
##    Installed Parsers ──────────── v2.8.1
##    Installed TranscodingStreams ─ v0.11.3
##    Installed CodecZlib ────────── v0.7.8
##    Installed WeakRefStrings ───── v1.4.2
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

One-line Docker commands are a lightweight, repeatable, and isolated way to test and explore code across environments—without cluttering your system. They’re particularly useful when comparing behaviour across language versions or running quick experiments in tools you don’t use daily.
