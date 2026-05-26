---
title: Building Apache Superset Home Setup
author: Konrad Zdeb
date: 2026-04-30
slug: building-apache-superset-home-setup
categories:
  - how-to
  - data
tags:
  - Apache Superset
  - Docker
  - Home Lab
draft: true
---

## Background

I was recently task with pro-bono helping on analysing some life science data. As I was expecting a lot of feedback on the lines of _can you show this like that._ This nice experience brought me close to my initial career days working as a researcher and analysts for various outfits. I wanted to Setting up a small analytics environment at home is surprisingly straightforward. The goal here is simple: run a lightweight instance of Apache Superset on a Debian laptop, allow multiple users on the local network to upload CSV files, and build basic dashboards.

This is not a production setup. It is a pragmatic, LAN-only system that gives you most of the value with minimal overhead.

The approach mirrors how I tend to structure quick technical experiments: keep dependencies simple, validate each step incrementally, and only harden where necessary.

---

## Architecture

The setup is intentionally minimal:

| Component    | Choice                     |
| :----------- | :------------------------- |
| BI tool      | Apache Superset            |
| Metadata DB  | PostgreSQL                 |
| Data storage | PostgreSQL (same instance) |
| Runtime      | Python virtual environment |
| Access       | Local network only         |

No Docker, no orchestration, no reverse proxy. Just enough to get a working system.

---

## System Setup

On a fresh Debian machine:

```bash
sudo apt update -y -V
sudo apt install -y -V \
  build-essential \
  libssl-dev \
  libffi-dev \
  python3-dev \
  python3-venv \
  python3-pip \
  libpq-dev \
  postgresql \
  redis-server
```

PostgreSQL is used both for Superset metadata and uploaded datasets.

---

## Database Configuration

Create database and user:

```bash
sudo -u postgres psql
```

```sql
CREATE DATABASE superset;
CREATE USER superset_user WITH PASSWORD '***';
GRANT ALL PRIVILEGES ON DATABASE superset TO superset_user;
```

Fix schema permissions (this one is easy to miss):

```sql
GRANT USAGE, CREATE ON SCHEMA public TO superset_user;
ALTER SCHEMA public OWNER TO superset_user;
```

Without this, Superset will fail during initialisation.

---

## Superset Installation

Create environment:

```bash
mkdir -p ~/superset
cd ~/superset
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install apache-superset psycopg2-binary
```

Create config:

```python
SQLALCHEMY_DATABASE_URI = "postgresql://<user>:<password>@localhost/superset"
SECRET_KEY = "***"
```

Initialise:

```bash
export SUPERSET_CONFIG_PATH=~/superset/superset_config.py
superset db upgrade
superset fab create-admin
superset init
```

---

## Running Superset (properly)

The built-in server works, but it is not designed for sustained use. Use Gunicorn instead:

```bash
pip install gunicorn gevent
```

Run:

```bash
gunicorn \
  --workers 4 \
  --worker-class gevent \
  --bind 0.0.0.0:8088 \
  "superset.app:create_app()"
```

At this point, Superset is available at:

```text
http://<machine-ip>:8088
```

---

## Systemd Service

To make it persistent:

```bash
sudo nvim /etc/systemd/system/superset.service
```

```ini
[Unit]
Description=Apache Superset
After=network.target postgresql.service redis-server.service

[Service]
User=jan
WorkingDirectory=/home/jan/superset
Environment="SUPERSET_CONFIG_PATH=/home/jan/superset/superset_config.py"
ExecStart=/home/jan/superset/venv/bin/gunicorn --workers 4 --worker-class gevent --bind 0.0.0.0:8088 "superset.app:create_app()"
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable:

```bash
sudo systemctl daemon-reload
sudo systemctl enable superset
sudo systemctl start superset
```

---

## Network Access

By default, Superset listens on all interfaces:

```text
0.0.0.0:8088
```

Restrict access to local network:

```bash
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw allow from 192.168.50.0/24 to any port 8088 proto tcp
sudo ufw enable
```

This ensures the system is available only within your LAN.

---

## Adding Data

Superset does not automatically expose your database.

You must:

1. Add PostgreSQL as a database connection
2. Enable:
   - “Allow file uploads”
   - Schema: `public` or `analytics`

Then upload CSV:

```text
Settings → Upload file to database
```

---

## Data Modelling

Superset expects structured data. Common fixes:

### Convert date column

```sql
SELECT date::date AS date, *
FROM analytics.sample_transactions;
```

### Add surrogate key

```sql
SELECT
  row_number() OVER () AS id,
  *
FROM analytics.sample_transactions;
```

Window functions require `OVER ()` — otherwise PostgreSQL will error.

---

## Visualisation Notes

Superset charts can behave unexpectedly if data is aggregated too early.

For example:

- Box plots require raw values
- Aggregations like `AVG(amount)` will collapse distributions

A practical workaround is to introduce row-level identifiers or aggregate at a controlled grain (e.g. per day).

---

## Users and Permissions

Create users via UI:

```text
Roles:
- Alpha
- sql_lab
```

This gives:

- dataset creation
- SQL access
- dashboard building

Avoid assigning Admin to regular users.

---

## Backups

A simple daily backup is sufficient:

```bash
sudo crontab -e
```

```cron
0 2 * * * sudo -u postgres pg_dump superset > /home/jan/backups/superset_$(date +\%F).sql
```

---

## Observations

A few things that stood out:

- Superset is powerful but UI-driven — SQL Lab is essential
- PostgreSQL permissions are the most common failure point
- Charts require understanding of aggregation behaviour
- Systemd + Gunicorn makes the setup stable enough for daily use

---

## What I Did Not Do

Deliberately omitted:

- Docker
- Reverse proxy (nginx)
- HTTPS
- External exposure

For a home setup, these add complexity without much benefit.

---

## Summary

What I have learned through that process is

This setup gives you:

- multi-user access
- CSV ingestion
- SQL exploration
- dashboarding

All running on a single Debian laptop.

It is not production-grade, but it is a useful and lightweight environment for experimentation, personal analytics, or small shared use.

As with most tooling setups, the key is not completeness, but sufficiency.
