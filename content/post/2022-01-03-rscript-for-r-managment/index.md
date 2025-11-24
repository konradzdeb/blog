---
title: Using RScript for R Installation Management
author: Konrad Zdeb
date: '2022-01-03'
slug: rscriptt-for-r-managment
categories:
  - how-to
tags:
  - bash
  - R
---

Most frequently, users tend to undertake common R installation and management tasks from within the R session. Frequently making use of commands, like `install.packages`, `update.packages` or `old.packages` to obtain or update packages or update/verify the existing packages. Those common tasks can also be  accomplished via the GUI offered within RStudio, which provides an effortless mechanism for undertaking basic package management tasks. This is approach is usually sufficient for the vast majority of cases; however, there are some examples when working within REPL^[REPL stands for **R**ead **E**val **P**rint **L**oop and is usually delivered in a form of an interactive shell. While working in Python users would commonly access REPLY by running `python` or `ipython`, [more details](https://pythonprogramminglanguage.com/repl/).] to accomplish common installation tasks is not hugely convenient.

For example, we may be utilising multiple library paths and our intention may be to update only one of the available libraries, which we use as a baseline for all new projects^[Projects like [`renv`](https://rstudio.github.io/renv/) and [Rocker](https://www.rocker-project.org) offer sophisticated ways of managing dependencies. Users intend to use R in production can definitely benefit from those developments.]. If our `.libPaths()` returns a content similar to the one below, we may be interested only in updating the first repository.


``` r
.libPaths()
## [1] "/Users/thisUserName/Library/R/4/library"
## [2] "/usr/local/Cellar/r/4.1.2/lib/R/library"
```

This outcome can be achieved using `update.packages(lib.loc =  .libPaths()[1])` but if our intention is to pass more arguments to the call, running this command frequently becomes more tedious and unnecessarily onerous. Python users will be familiar with Conda and pip and, while working in R, may be longing for a solution offering a similar, convenient command line mechanism facilitating execution of basic installation and package management tasks. For instance in Conda we would simply do `conda install package-name=2.3.4` to install a package of a specific version. Similarly we can simply run `conda update --all -y` to update all packages unprompted or pass further arguments to update packages within a specific environment and so forth. Pip offers a number of similar convenience features.

## "Requirements"

I was interested in at a R-based solution that would offer a comparable level of convenience. However, as R does not offer package management mechanism that would be out of the box accessible via command line. 

## Solution

R offers two interfaces for running scriptts and commands without starting an interactive session: `R CMD` and `RScript`^[Less known [`littler`](http://dirk.eddelbuettel.com/code/littler.html) projects offers some excellent functionalities that are worth exploring for users keen on exploiting R's command line front end capabilities.]. `R CMD` is an older interface facilitating command and scriptt execution via command line. `Rscriptt` came later and is, in general, more flexible. Readers interested in the subject should start research from [this StackOverflow](https://stackoverflow.com/q/21969145/1655567) discussion that provides a good primer on key differences.

## Updating Packages

In the process of updating packages we will be usually interested in achieving two goals:

* Identifying any outdated packages that may benefit from updating
* Running an update for outdated packages every so often. This is relatively good habit, comparable to running `brew upgrade` with some frequency so we can avoid our production environment staying far behind current stable releases.

### Outdated packages

For a start, let's attempt to construct a data frame containing the outdated packages using `Rscriptt`. This is achieved in the following manner


``` bash
Rscriptt --no-save --no-restore --no-init-file \
        -e 'as.data.frame(old.packages(repos = "https://cran.rstudio.com"))[,-c(1,6)]'
```

If we intend to execute this command frequently it may be useful to wrap in a function. As we are not intending to pass any arguments to the function this is trivial:


``` bash
function routdated () {
        Rscriptt --no-save --no-restore --no-init-file \
        -e 'as.data.frame(old.packages(repos = "https://cran.rstudio.com"))[,-c(1,6)]'
}
routdated
```


#### Outdated packages explanation

Let's break this down. `Rscriptt` can be run with multiple switches:

* `--no-init-file` skips reading of the `.Rprofile` files. As I keep my library path stored within the `Renviron` file, I'm skipping processing of the `.RProfile` file. Traditionally, `.RProfile` is used to configure default repositories but I pref to specify the repository directly in the call as I want to update against RStudio's one
* `--no-save` prevents `RScript` from saving data on exit
* `-e` is used to specify the call that `RScript` is expected to execute

A point of note, if you specify your library paths using `RProfile` file you may need to remove the `--no-init-file` switch.

## Installing packages

Installing packages from console is useful if we want to undertake those tasks outside the ongoing workflow. Let's say that we are working on a project and looking for package facilitating quick generation of tabular summaries or some relevant visuals. We could use `install.packages` from the REPL session we are in but if the package is requiring compilation we are get quite a lot of output that is not pertinent to the task at hand. Another common approach would be to start another session and run install command there. RStudio also facilitates running background processes but that's a little bit of an overkill for a simple task.

A sensible middle ground solution would be to run the package installation via `RScript` we could conveniently call it as a background process or just start in a new tab when working with any popular terminal client supporting this functionality. 


``` bash
## Function body
function rinst () {
	declare pkgnme=$1
	Rscriptt --vanilla -e "install.packages('$pkgnme', dependencies = TRUE, repos = 'https://cloud.r-project.org/', lib = '/Users/konrad/Library/R/4/library')"
}
```

### Explanation

As I want for this function to install only to a specific library and from a specific repository I'm using the `--vanilla` switch to let Rscriptt know that I don't need it to process `.RProfile` and other files in this particular call as I'm storing the relevant arguments within the function.

## Summary

In all likelihood, for more sophisticated projects solutions like [`renv`](https://rstudio.github.io/renv/) and [Rocker](https://www.rocker-project.org) are a way to go. Nevertheless combination of Rscriptt / bash can prove very efficient in quickly accomplishing routine maintenance tasks. 
