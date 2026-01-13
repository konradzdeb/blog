---
title: Codex Calendar Planning Tool
author: Konrad Zdeb
date: 2026-01-12
slug: codex-calendar-app
categories:
  - productivity
  - tools
tags:
  - Codex
  - Calendar
  - Planning
draft: true
description: Draft stub for the Codex-based calendar planning tool article.
---

When my ex wife asked to spend more time with our son, I was open to it but needed to make sure his extracurricular schedule stayed intact. I wanted to plan out his weeks with every activity and school collection time clearly marked, so I defined a few requirements up front: a clean, printable calendar view, no paid app or subscription for something I would not use often, and a way to subscribe or export the calendar so it stays visible across all of my devices.

## Background

I first looked at Apple Calendar, but its printing options are limited and a presentable, readable calendar was non-negotiable. Fantastical would cover everything I needed, yet I was not keen to buy a license for a one-off need. I also considered using something like InDesign with scripting to build a polished calendar, but that felt like overkill and would have required learning additional tooling and writing a fairly complex calendar builder. Google Calendar had similar printing limitations. Given all of that, building a small software package felt like the right choice: I could script the visuals and color coding, export to ICS, and control schedule changes via versioned JSON files.

Since this was a fairly informal, one-off event, I decided to vibe-code it with Codex (see-no-evil icon).

## What is Codex

Codex is OpenAI's coding agent that works inside the terminal, taking natural language requests and then reading and editing files or running commands to complete tasks. In practice it feels like a pair programmer with tool access, so I can describe the outcome and let it stitch together code and assets quickly. By comparison, [Crush](https://github.com/charmbracelet/crush) is a terminal app from Charmbracelet that wires your tools, code, and workflows into the LLM of your choice, with multi-model support, session context, LSP-backed signals, and MCP extensibility. I've been using Crush a lot and I've been happy with how it handles small-to-medium complexity projects, mostly for macOS and iOS hobby app development. For this project, I was looking for an opportunity to give Codex a proper ride. Codex is more of a focused, guided workflow, while Crush is a configurable TUI that you can point at whichever models you prefer.

## Development

For testing and experimentation, I decided to make the development fully vibe-coded. I only occasionally opened files in Neovim to check the changes, but since the project was informal, I wanted to take the vibe-coding approach all the way.

## Problem

Outline the planning pain points this tool solves.

## Solution

Explain how the Codex-based calendar workflow works.

## Implementation notes

Add key architecture and data flow details.

## Results

Summarize outcomes, metrics, or lessons learned.
