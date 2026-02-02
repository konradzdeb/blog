---
title: "Building a Fraud Detection Pipeline with MLflow"
author: "Konrad Zdeb"
date: "2026-02-02"
slug: "mlflow-fraud-pipeline"
draft: true
categories:
  - how-to
tags:
  - Python
  - MLflow
  - Fraud
  - MLOps
  - ML
---

## Scope

This post shows a minimal, practical fraud detection pipeline in Python using MLflow:

- Local tracking store for reproducibility
- Model registry workflow
- Batch scoring and near-real-time micro-batch scoring
- Notes on switching artifacts to cloud storage

All examples use synthetic data to avoid confidentiality issues.

## Outline

### 1) Problem framing (fraud is cost-sensitive)

- Class imbalance and cost asymmetry
- Why threshold selection matters more than AUC alone

### 2) Synthetic dataset (reproducible + imbalanced)

- Basic generator
- Optional drift knob

### 3) Feature pipeline (minimal)

- Simple behavioral aggregates

### 4) Training + evaluation

- Baseline model (logistic or XGBoost)
- Cost-based metric logging in MLflow

### 5) MLflow tracking (local)

- Params, metrics, artifacts, model signature

### 6) Registry workflow

- Register model
- Transition to "Staging"
- Promotion criteria

### 7) Storage note (cloud-ready)

- Local file store now
- S3/GCS/Azure Blob drop-in for artifacts

### 8) Scoring

- Batch scoring example
- Micro-batch scoring (near-real-time)
- Persist scores + audit trail

### 9) Operational guardrails (lightweight)

- Score distribution checks
- Alert volume monitoring

## Code structure (planned)

- `data_generator.py`
- `train.py`
- `register.py`
- `score_batch.py`

## Next steps

- Flesh out minimal code examples per section
- Add short troubleshooting notes (MLflow local store path, registry config)
