---
title: Using Python Models in DIY Mobile Applications
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


# Python's Model

For the purpose of demonstration we will create basic modelling solution in Python 

```r
"""Example model training solution."""

from sklearn.datasets import load_iris  # noqa: E0401
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split

# Load data
iris = load_iris()
X, y = iris.data, iris.target
```
