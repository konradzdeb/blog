---
title: Using Python Model in Swift
author: Konrad Zdeb
date: '2025-05-02'
slug: python-modesl-app
categories:
  - how-to
tags:
  - swift
  - ML
  - Python
---

Arrival of CoreML Framework in June 2017 open up an exciting possibility of productionings models on Apple devices. This is particulary attractive in the context of deploying ML-reliant applications on mobile devices, offerring access to a signficiant market. In order to introduce a ML solution into a Swift-based sofwtare product `.mlmodel` file would need to be produced. The two common mechanisms facilitating that process are:
1. Leveragining Apple's Create ML App or Create ML framework (for programmatic model creation)
2. Leveraging `coremltools` Python package and preparing model elsewhere to be imported into the production

Create ML App offers fairly limited interface for model development tasks

# Python's Model
