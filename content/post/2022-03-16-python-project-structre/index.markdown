---
title: On structuring Python Projects
author: Konrad Zdeb
date: '2022-03-16'
slug: python-project-structre
draft: true
categories:
  - dev
  - example
tags:
  - Python
---

## Types of projects

Personally, I find that reference to a *Python project* is somehow misleading. Whereas languages conceived for a precisely definable purpose such as Swift, which is used to generate macOS/iOS apps, components and framework, Python is used more versatilely. A *Python project,* may reflect analytical solution developed across multiple Jupyter notebooks, a standalone script querying database API and extracting a result to file an application or package facilitating deployment of models. Each of those projects will have some key usability requirements. For instance, if we envisage that end users will utilise our project through command line interface we will focus on argument parsing and other elements facilitating user-friendly execution.

### Data Science, Model, Tool and Hybrid

In business practice, I have came across a few common types of projects. The distinction I draw between pure *data science* and *model* projects is somehow arbitrary and frequently blurred but useful. I draw my 

### Time horizon

The time horizon approach to project structure is hugely beneficial as it enables us to narrow down a gap between the complexity of the project scaffolding and time horizon. If visualised 

<img src="{{< blogdown/postref >}}index_files/figure-html/line_plot_complexity-1.png" width="672" />


## Set-up

## File structure

Whereas in certain scenarios we may get away with a single file set-up any wider collaboration is usually easier if the project structure spans across multiple files

## Testing

## `setup.cfg` / `setup.py`

In majority of the cases using `setup.cfg` is a better solution. Whereas users may find it tempting to leverage Python's flexibility in creating assertion like

# Summary

In business and any
