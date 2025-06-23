---
title: Using Python ML Models in DIY Mobile Applications
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

Arrival of CoreML Framework in June 2017 open up an exciting possibility of productionings models on Apple devices. This is particulary attractive in the context of deploying ML-reliant applications on mobile devices, offering access to a significant market. In order to introduce a ML solution into a Swift-based sofwtare product `.mlmodel` file would need to be produced. The two common mechanisms facilitating that process are:
1. Leveragining Apple's Create ML App or Create ML framework (for programmatic model creation)
2. Leveraging `coremltools` Python package and preparing model elsewhere to be imported into the production


# Python's Model

For the purpose of demonstration we will create basic modelling solution in Python 

```r
"""Example model training solution."""

from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from yellowbrick.classifier import ClassificationReport

# Load data
iris = load_iris()
X, y = iris.data, iris.target

# Load data
X, y = load_iris(return_X_y=True)

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Train model
model = RandomForestClassifier(random_state=42)
model.fit(X_train, y_train)

# Visualise model results
viz = ClassificationReport(model, support=True, classes=iris.target_names)
viz.score(X_test, y_test)
viz.show()
```


Following execution of that code we get an unsophisticated model.

/Users/konrad/.virtualenvs/swiftml/lib/python3.13/site-packages/yellowbrick/classifier/base.py:232: YellowbrickWarning: could not determine class_counts_ from previously fitted classifier
  warnings.warn(
<img src="{{< blogdown/postref >}}index_files/figure-html/run_python_code-1.png" width="672" />

The key challenge would be brining the model into the 
