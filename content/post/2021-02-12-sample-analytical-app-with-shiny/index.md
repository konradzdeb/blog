---
title: Poor Man's Robust Shiny App Deployment (Part II)
author: Konrad
date: '2021-02-12'
slug: sample-analytical-app-with-shiny
categories:
  - dev
  - how-to
tags:
  - R
  - Shiny
  - R-package
---


# Introduction

This article draws on the past post concerned with utilisation of [`golem`](https://github.com/ThinkR-open/golem) for robust deployment of analytical and reporting solutions. For this article, we will assume that we are working with defined working requirements that utilise some of the Labour Market Statistics disseminated through the [*nomis*](https://www.nomisweb.co.uk) portal.

## Change Plan

**What we have**

-   Reporting requirements
-   Past scripts we used to create reports with accompanying instructions

**What we want**

-   *Stronger business continuity* - we want to be able to give some access to this project and don't be concerned with missing files, outdated unavailable documentation and questions on how to produce updated reports. We want self-encompassing entity that takes of care of its technical requirements and user-interaction[^1]

-   *Better reproducibility* - Easier way to re-run reports on custom parameters

-   *Improved efficiency* - We want to have a possibility of quickly creating updated and re-running past reports using the app.

-   *Better development:*

    -   We want to ensure that any change requests to our reporting/analytical stack won't break crucial functionalities.
    -   We want to modularise development so new corporate branding or visualisation requirements can be applied with no (or minimal) integration in analytical function

# Framework

## Package

Future robust development owes a lot to solid foundations. As the aim is to capitalise on the robust R package architecture, we will look to leverage available supporting packages. As a first step, we will construct a new Shiny/R package infrastructure using `golem`.

``` r
golem::create_golem(path = "nomisReports")
```

Running package with default options gave us the following folder structure:

``` r
.
├── DESCRIPTION
├── dev
│   ├── 01_start.R
│   ├── 02_dev.R
│   ├── 03_deploy.R
│   └── run_dev.R
├── inst
│   ├── app
│   │   └── www
│   │       └── favicon.ico
│   └── golem-config.yml
├── man
│   └── run_app.Rd
├── NAMESPACE
├── nomisReports.Rproj
├── R
│   ├── app_config.R
│   ├── app_server.R
│   ├── app_ui.R
│   └── run_app.R
└── sessionInfoLog

7 directories, 15 files
```

The structure corresponds to what we would expect to find in a traditional package development. Thee are number of files specific to golem, which are explained later.

## Using `usethis`

Pacakge structure is a scaffolding that can be used to develop package functionalities and integrate remaining, subsequent articles focus on leveraging robust and tested methods for assembling our package development scaffolding, such as [`usethis`](https://usethis.r-lib.org) package that offers a variety of commands facilitating adding package elements.

[^1]: Good parallel can be drawn between this approach and manuals available with life-saving equipment. Equipment delivers technical capacity and manual ensures operational capacity. In case of an inexperienced user one is not useful without the other. We want to ensure that user with minimum required capacity can use the tools correctly.
