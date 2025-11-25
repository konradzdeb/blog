---
title: Using build pre-post actions to observe default changes
author: Konrad Zdeb
date: 2025-11-24T16:01:56.305Z
categories:
    - dev
tags:
    - Swift
    - Xcode
    - macOS
draft: false
description: How to exploit pre-/-post-actions available in Xcode to observe changes in defaults.
slug: build-pre-post-actions-observe-default
---

The following article provides guide on scheme build and run pre-/post actions in Xcode to manage creation and modification of defaults through external logging through the application.

## What are Defaults

In Swift and macOS development, defaults (via `UserDefaults` and the `defaults` CLI) are the lightweight persistence layer for user preferences, feature toggles, and other small pieces of state that need to survive app relaunches. They sit between in-memory settings and heavier storage options, letting you read and write simple values keyed by domain so the same code works in app code, Xcode schemes, and shell scripts. Because defaults are global to a domain, careful naming and cleanup are essential to avoid collisions and stale settings during development.

For a deeper dive, Fatbobman’s [“UserDefaults and Observation in SwiftUI”](https://fatbobman.com/en/posts/userdefaults-and-observation/) is a solid blueprint: Xu Yang shows why Observation alone misses external changes, then patches the gap with an `@ObservableDefaults` macro that keeps SwiftUI views in sync with UserDefaults regardless of where writes originate. This is, excellent, disciplined approach which centralizes keys, respond to external mutations, and choses lightweight persistence over ad-hoc state—maps well. For the remaining part of this article I will be using this approahc.

## Challenge

When building a macOS application that stores defaults I was keen to see what the application writes to the defulats store. In particular, I would like to be able to meet two objectives:

1. Enable reporting of the defaults changes following build, run and closure of the application
2. Get live visbilty of the defaults changes
3. I would like to be able to do the above independently of the application run

## Solution
