---
title: Review MLeng Datacamp Course
author: Konrad Zdeb
date: 2025-08-31
slug: review-mlend
categories:
  - review
tags:
  - DataCamp
  - MLEng
  - Learning
  - PDP
draft: true
description: Review of MLEng course on Data Camp
---

As a data science lead, I consider it my responsibility to guide junior data scientists on training and professional development. The field is diverse, and I often see two common profiles: those with strong mathematical and statistical foundations but limited experience in software engineering (for example, object-oriented programming, unit testing, and CI/CD), and those with solid computer science backgrounds but less exposure to the mathematical side. To make informed professional development recommendations, I regularly complete courses and learning exercises myself and have made a habit of working through material daily. In this post, I review DataCamp’s Machine Learning Engineering course, which I recently completed.

## Course

The course is organised as a set of theoretical and practical modules, plus independent projects. The practical modules typically focus on specific tools. For instance, data versioning is taught with DVC, and data quality with Great Expectations.

## Things that I liked

The theoretical side is, in my view, its strongest asset. The track offers modules on model management and the ML lifecycle, grounding these concepts in established engineering practice.

## Mixed view

I have mixed views on the practical components. Some modules—such as those on using MLflow for model deployment and DVC for data version control—are well placed and genuinely useful. Others are more debatable. For example, ETL/ELT is demonstrated using Pandas. While Pandas is widely used by analysts and helpful for many data engineering tasks, relying on it alone is often insufficient for production-grade pipelines.

# Things I didn't Like

Two modules could be improved. The "Introduction to Shell" module covers Bash by guiding learners from simple commands (e.g., cp, grep) to writing basic scripts. The concept is solid, but the delivery feels uneven: it emphasises memorising commands over practical workflows such as piping, redirection, error handling, and reproducible scripting. A stronger focus on real-world tasks—data inspection, batch processing, and automation—would make it more effective.