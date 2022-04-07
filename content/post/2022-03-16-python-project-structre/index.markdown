---
title: On structuring Python projects or collection
author: Konrad Zdeb
date: '2022-03-16'
slug: python-project-structre
categories:
  - dev
  - example
tags:
  - Python
---

# Types of projects

Personally, I find that reference to a *Python project* is somehow misleading. Wheras languages conceived for a presisly definable purpose such as Swift, whcih is used to generate macOS/iOS apps, components and framework, Python is used more versitaly. A *Python project,* may reflect analytical solutiuon developed across multiple Jupyter notebooks, a standalone script querying database API and extractacting a result to file an application or package facilitating deployment of models. Each of those projects will have some key usability requirements. For instance, if we envisage that end users will utilisie our project through command line interface we will focus on argument parsing and other elements facilitating user-friendly execution.

# Set-up

## File structure

Whereas in certain scenarios we may get away with a single file set-up any wider collaboration is usually easier if the project structure spans across multiple files

## Testing

## `setup.cfg` / `setup.py`

In majority of the cases using `setup.cfg` is a better solution. Whereas users may find it tempting to leverage Python's flexibility in creating assertion like

# Summary

In business and any 
