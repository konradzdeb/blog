---
title: Version Control your Dotfiles
author: Konrad Zdeb
date: '2025-03-14'
slug: git-dotfiles
categories:
  - fun
  - how-to
tags:
  - git
  - dotfiles
---

![Using git to version control dotfiles](images/imageGitStatus.png)

# What are .dotfiles?

Dotfiles are configuration files on Unix-like systems that begin with a dot (.) and are usually hidden by default. They store settings and preferences for various applications and system tools, such as shells, editors, and version control systems. By keeping configurations in these hidden files, users can easily customize their environments, share settings across different machines, and maintain consistency in their workflows. Some files end up in the `~/.config/` directory because many modern Linux and Unix-like programs follow the XDG Base Directory Specification, which recommends storing user-specific configuration files in the `XDG_CONFIG_HOME` directory (usually `~/.config`). This approach helps keep user home directories less cluttered by grouping all configuration files in one organized location, making it easier to manage, back up, or share custom settings across systems.

# Implementation

In order to control .dotfiles across multiple locations we need to create a special version of the git repository. 

# Practical example

Successfully implementing git-based version control of dotfiles allows for tracking of all changes to the configuration files. In addition, the approach also permits for efficient testing of configuration via git's branching mechanism. The last option is particulary exciting if we want to experiment with more complex configuration settings. 
Let's consider following scenrio. I like to use nvim for majority of my coding work. NVim has exceptionally riach plugin ecosystem, well-established vim plugins can be used alongside nvim-specific extensions written mostly in Lua. I manage my NVim plugin configuration using Lazy, with multiple `*.lua` files storinh configurations for specific plugins. For instance, my nvim configuration is scattered across a number of Lua files. In effect my NVim configuration looks as follows:


``` bash
tree ~/.config/nvim -P '*.lua' --prune
```

```
## /Users/konrad/.config/nvim
## ├── init.lua
## └── lua
##     ├── config
##     │   └── lazy.lua
##     └── plugins
##         ├── R.lua
##         ├── autolist.lua
##         ├── autopairs.lua
##         ├── autosession.lua
##         ├── code-runner.lua
##         ├── codecompletion.lua
##         ├── conform.lua
##         ├── gruvbox.lua
##         ├── kanagawa.lua
##         ├── lsp.lua
##         ├── lualine.lua
##         ├── mason.lua
##         ├── neogen.lua
##         ├── neogit.lua
##         ├── neotree.lua
##         ├── nvim-ts-autotag.lua
##         ├── nvimlint.lua
##         ├── orgmode.lua
##         ├── snippets.lua
##         ├── startup.lua
##         ├── telescope-undo.lua
##         ├── telescope.lua
##         ├── templates.lua
##         ├── treesitter.lua
##         └── wilder.lua
## 
## 4 directories, 27 files
```

## Adding R support

I would like to enhance my NVim installation to support better working with R files. In general, I'm  looking to:
* Have a convenient ability to run R code, focusing on running whole stcripts, or more frequently, selected parts of code I'm working on.
* Consistent evaluation of the R code in one environment




