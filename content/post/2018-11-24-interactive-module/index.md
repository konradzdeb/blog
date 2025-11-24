---
title: Interactively Loading Shiny Modules
author: Konrad
date: '2018-11-24'
slug: interactive-module
categories:
  - how-to
  - BI
tags:
  - R
  - Shiny
---

## TL;DR

If you want to see the implemented solution, please refer to: 
GitHub repo.

## Context

Shiny is a widely popular web application framework for a R. In simple tearms it enables any R programmer to develop and deploy web application. This application could be simple - an interactive document consisting of a few charts and tables or a c complex "behemoth" with multiple functionalities enabling end-users to run models, query external data, generate exportable reports and sophisticated visuals. 

In business, it is frequently efficient to capitalise on existing solution and develop / upgrade existing products. In a business intelligence web application context this may mean adding modules and functionalities to an existing application so a wider audience can be served and more user needs can be met.

This has certain advantages, mostly:

- Deployment cycle is faster, we are working on an existing product and adding new functionalities
- We are leveraging existing dissemination mechanism, authentication, server, data connections. Where possible we can use tested and working solutions. This is conducive to stability.
- Testing will be easier as we have an established user group that is familiar with the product

## Challenges

Challenges are more interesting, as this is what I'm going to discuss. The challenges can be grouped in two main themes:

- Development
- User exeperience

## Development

Let's address development challenges first. Traditionally Shiny application would consist of `server.R` and `ui.R`. Each file containing function definitions for server and user interface. Recently both of those are saved as in one file as in examples provided with Shiny package. To see available examples run:


``` r
list.files(
    path = system.file("examples", package = "shiny"),
    pattern = glob2rx("*.R"),
    recursive = TRUE,
    full.names = TRUE
)
```

Now this won't fly. Best case scenario we will end-up with [sphagetti code](https://craftofcoding.wordpress.com/2013/10/07/what-is-spaghetti-code/) mostly likely we will end up with nothhing. 

### Modules

Modueles solve that problem by breakig down application architecture into 
