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

This post walks through the current `MLFlowFraud` project.

The pipeline is intentionally simple and local-first:

- Synthetic transaction stream into Redis
- MLflow server for experiment tracking and model registry
- Micro-batch stream consumption for near-real-time monitoring/scoring
- A clean path to move artifact storage to cloud later

All data is synthetic, so we can iterate on ideas without touching sensitive customer data.

## 1) Problem framing (fraud is cost-sensitive)

Fraud detection is not a standard "maximize accuracy" problem. False negatives are expensive, and false positives hurt customer experience. That means:

- Class imbalance is expected
- Threshold choice matters more than one headline metric
- Operational signals (alert volume, drift, latency) matter as much as offline model quality

The project reflects that mindset by first building reliable event generation and observability, then layering training and registry workflows.

## 2) Synthetic dataset (reproducible + imbalanced)

The generator (`scripts/generate_events.py`) creates realistic-ish card transaction events with controllable fraud rate, user/merchant behavior, and out-of-order timestamps.

Core generation flow:

```python
def generate_event(...):
    user = rng.choices(users, weights=user_weights, k=1)[0]
    merchant = rng.choices(merchants, weights=merchant_weights, k=1)[0]

    channel = rng.choice(DEFAULT_CHANNELS)
    amount = rng.lognormvariate(2.6, 0.9) * (user.avg_amount / 40.0) * merchant.risk
    amount = max(1.0, min(amount, 5000.0))

    ip_country = user.home_country
    if rng.random() < 0.08:
        ip_country = rng.choice([c for c in DEFAULT_COUNTRIES if c != user.home_country])

    fraud_prob = base_fraud_rate * user.risk * merchant.risk
    if ip_country != user.home_country:
        fraud_prob *= 2.5
    if amount > 500:
        fraud_prob *= 1.8
    if channel == "ecom":
        fraud_prob *= 1.3
    fraud_prob = min(fraud_prob, 0.9)
```

Out-of-order behavior is configurable:

- `OUT_OF_ORDER_RATE`
- `LATE_SECONDS_MAX`

That gives us realistic stream quirks for testing micro-batch consumers.

## 3) Feature pipeline (minimal, event-native)

Instead of a heavy feature store, each event already contains useful model-ready signals:

- `amount`
- `channel`
- `card_present`
- `ip_country`, `home_country`
- `seconds_since_last`
- `merchant_category`

This keeps the first version lightweight. For many baselines, you can derive useful flags directly:

```python
country_mismatch = int(event["ip_country"] != event["home_country"])
high_amount = int(float(event["amount"]) > 500.0)
is_ecom = int(event["channel"] == "ecom")
velocity = float(event["seconds_since_last"])
```

## 4) Training + evaluation (baseline pattern)

The current repo focuses on streaming + infra. For model training, I use a baseline pattern:

- Start with logistic regression or tree-based baseline
- Track precision/recall at chosen threshold
- Track business-weighted cost

Example cost metric:

```python
def fraud_cost(fp: int, fn: int, cost_fp: float = 1.0, cost_fn: float = 25.0) -> float:
    return fp * cost_fp + fn * cost_fn
```

This simple metric is often more actionable than optimizing AUC alone.

## 5) MLflow tracking (local)

The local stack is managed with Docker Compose:

```bash
docker compose up --build
```

Services:

- Redis: `localhost:6379`
- MLflow UI: `http://localhost:5001`
- Generator service streaming into Redis Stream `transactions`

From `docker-compose.yml`, MLflow is configured as:

```yaml
mlflow:
  command: >
    mlflow server
    --backend-store-uri sqlite:///local/mlflow.db
    --default-artifact-root /app/local/mlflow
    --host 0.0.0.0
    --port 5000
```

This gives reproducible local tracking with persistent state under `local/`.

Minimal logging pattern in training/scoring code:

```python
import mlflow

mlflow.set_tracking_uri("http://localhost:5001")
mlflow.set_experiment("fraud-baseline")

with mlflow.start_run(run_name="baseline-logreg"):
    mlflow.log_param("threshold", 0.35)
    mlflow.log_metric("precision", precision)
    mlflow.log_metric("recall", recall)
    mlflow.log_metric("cost", cost)
```

## 6) Registry workflow

Even in a local setup, using the MLflow registry early is useful:

1. Register baseline model version from a completed run
2. Promote to `Staging` when metrics and sanity checks pass
3. Promote to `Production` only with explicit criteria (cost + alert-volume budget)

Promotion criteria I like for this setup:

- Recall above agreed floor
- Fraud-cost metric below previous production baseline
- Stable daily alert volume

## 7) Storage note (cloud-ready)

Right now artifacts are local (`/app/local/mlflow`). Moving to cloud later is mostly a config change:

- S3: `s3://...`
- GCS: `gs://...`
- Azure Blob: `wasbs://...`

Keep backend metadata store and artifact store decisions explicit so promotion from local to shared environments is painless.

## 8) Scoring (batch + micro-batch)

The project already includes a stream tail utility:

```bash
python scripts/tail_events.py --stream-name transactions --start '$' --count 10
```

`scripts/tail_events.py` reads Redis Stream events continuously and prints formatted lines, with color emphasis for suspicious/fraud events.

For a first micro-batch scoring loop, read from Redis in small batches, enrich features, score, then emit an auditable result record (CSV, DB table, or another stream). Keep input event id + score + threshold + model version together so decisions are traceable.

## 9) Operational guardrails (lightweight)

A minimal operations checklist that pays off quickly:

- Monitor score distribution shifts
- Track alert counts per hour/day
- Track event lag (event time vs ingestion time)
- Alert on consumer stalls and Redis backlog growth

For this local project, even simple scripts that log these stats into MLflow metrics are enough to catch issues early.

## Runbook summary

Create the project (uv-managed):

```bash
uv init --app --no-package --name mlflow-fraud --description "MLflow-based fraud detection pipeline examples with batch and micro-batch scoring." --vcs git
```

Start local stack:

```bash
docker compose up --build
```

Watch stream events:

```bash
python scripts/tail_events.py --stream-name transactions --start '$'
```

Open MLflow UI:

- `http://localhost:5001`

## Closing notes

This implementation is intentionally practical:

- Build reliable synthetic stream + observability first
- Keep feature engineering close to events
- Use MLflow tracking + registry discipline from day one

That creates a solid base for the next increment: formal training scripts and automated promotion gates.
