---
title: Using R for File Manipulation
author: Konrad Zdeb
date: '2021-03-29'
slug: file-manipulation-in-r
categories:
  - how-to
tags:
  - R
references:
- id: Christensson
  title: One-click science marketing
  author:
  - family: Christensson
    given: P.
  URL: 'https://techterms.com'
  publisher: Nature Publishing Group
  type: webpage
  issued:
      year: 2011
      month: September
      day: 23
---

# Challenge

File manipulation is a frequent task unavoidable in almost every IT business process. Traditionally, file manipulation tasks are accomplished within the ramifications of specific tools native to a given system. As such, the one may consider writing and scheduling shell script to undertake frequent file operations or using more specific purpose-built tools like [`logrotate`](https://linux.die.net/man/8/logrotate) in order to archive logs or tools like [Kafka](https://kafka.apache.org/20/documentation.html) are used to build streaming-data pipelines. R is usually though of as a statistical programming language or as an environment for a statistical analysis. The fact that R is a mature programming language able to successfully accomplish a wide array of traditional tasks is frequently ignored. What constitutes a *programming language* is a valid question. Wikipedia offers somehow wide definition:

> A programming language is a formal language comprising a set of instructions that produce various kinds of output. Programming languages are used in computer programming to implement algorithms.

[*Wikipedia*](https://en.wikipedia.org/wiki/Programming_language)

# Pros and Cons of Using R as an ETL solution

- The article assumes that consideration on whether to utilise R within a team for pure ETL tasks is usually given in the context of R language being utilised to greater or lesser degree to facilitate data modelling, analytical or statistical work. R wasn’t designed to replace ETL[^1] processes; nevertheless, as every other well-developed programming language R offers a set of robust tools for accomplishing file manipulation, analysis and creation. In particular, R package ecosystem offers a layer that provides a clean, **unified,** interface for accomplish a variety of tasks, which traditionally, would be solutioned using system tools or bespoke applications.

## Pros

- Ability for our production process to be migrated across the systems and configurations increases. Let’s consider a simple example of generating temporary files. Utilising R base function `tempfile` or equivalent call from the `fs` package, `fs::file_temp()` allows for swift creation of temporary files. Achieving that on MS Windows using PowerShell could be done using specific cmdlet called *New-TemporaryFile:* `$tmp = New-TemporaryFile`. When working in command prompt we would leverage `%TEMP%` and `%RANDOM%` environment variables to come up with something like `set "uniqueFileName=%tmp%\bat~%RANDOM%.tmp"`, as discussed at lengths in [the related Stack Overflow answer](https://stackoverflow.com/a/32109191/1655567), which suggests this answer:

``` coffee
@echo off
setlocal EnableExtensions

rem get unique file name 
:uniqLoop
set "uniqueFileName=%tmp%\bat~%RANDOM%.tmp"
if exist "%uniqueFileName%" goto :uniqLoop
```

The point is that exercises like that incur additional maintenance cost. Whereas `tempfile` is straightforward, well documented and understood by every R user; more importantly we achieve uniform cross-system implementation, which will make our project easier to maintain.

- Thanks to the [Rocker Project](https://www.rocker-project.org) R plays exceptionally well with Docker. This is conducive to reducing future maintainability costs and enhancing portability. Decent article covering technicalities of using Docker with R was provided by Colin Fay.[^2]

- R has rich ecosystem offering API connectivity. Thanks to [Plumber](https://www.rplumber.io) R users can, with relatively little effort, generate own APIs. Packages like [wbstats](https://github.com/gshs-ornl/wbstats) and [Eurostat](https://github.com/rOpenGov/eurostat) provide convenient wrappers for sourcing data from publicly available repositories (article World Bank and Eurostat). Those can be immensely time server if we consider building processes that rely on background external demographic/macroeconomic data being incorporated in our processes on regular basis. The subject of R / API integration merits a separate article.

- File format conversion. Through packages like [haven](https://haven.tidyverse.org/) R offers rich interface to access data in different formats (Stata, SPSS, etc.). When working with bloated legacy processes that may required handling input originating from heterogeneous sources (think SAS binary, in-house Oracle database and some periodical figures produced by World Bank) the R flexibility may prove actual life saver. Still we should be careful not to use R as an excuse not to refactor and clean up old production processes.

## Cons

- Using R for file manipulation is not suitable for processes that are mostly in vast majority ETL tasks. If our intention is to monitor a location for change and then conditionally copy files building R-based process will incur an unnecessary dependency, whereas more tools would

- Achieving fine-grained control over common operations may be more difficult in R. Let’s consider `rsync`. The Internet is full of examples on how to achieve properly defined goals using `rsync`, it is also possible to find Python implementation of the algorithm[^3]. At the time of writing this article, the attempts to bring `rsync` functionality relied on command line tool.[^4]

- Multi-threading, the thinking around multi-threading and asynchronous computation in R oscillates around finding more efficient ways to accomplish computational effort. Whereas packages like [r-lib/async](https://github.com/gaborcsardi/async) or [r-lib/processx](https://github.com/r-lib/processx) offer approaches to run processes in the background or perform asynchronous I/O operations; those solutions are applicable to more complex process. Achieving parallel `rsync` execution can be easily achieved using `xargs`, as found on Stack Overflow[^5]:

``` bash
ls /srv/mail | xargs -n1 -P4 -I% rsync -Pa % myserver.com:/srv/mail/
```

## Packages worth looking at

When discussing efficiencies derivable from R in the context of file manipulation it’s worth to mention a suitable packages as available

| Package | Description |
|:---|:---|
| [fs](https://github.com/r-lib/fs) | Cross-platform, uniform interface for file manipulation |
| [processx](https://github.com/r-lib/processx) | Executing and controlling system processes |
| [zip](https://github.com/r-lib/zip) | Cross-platform zip compression in R |
| [rsync](https://github.com/INWTlab/rsync) | R wrapper around rsync |
| [sftp](https://github.com/stenevang/sftp/) | SFTP for R |
| [eurostat](https://ropengov.github.io/eurostat/), [wbstats](https://github.com/gshs-ornl/wbstats) | For accessing publicly available data |

# Conclusion

The R-based file manipulation process are only efficient, from a production perspective, when applied to processes containing a substantial analytical/statistical component. R also lends itself exceptionally to handling processes with heterogeneous inputs and outputs. By leveraging R we can bring order to processes that, before, had to utilise multiple tools to access disparate databases and ingest binary outputs. If our production process utilise common publicly available data repository, there is a strong chance that R package ecosystem can provide a convenient wrapper that makes regular querying and refreshing a breeze. R-based ETL exercises may prove unnecessary onerous if our intention is to develop multi-thread, asynchronous solutions. If our sole purpose is to run multi-thread rsync, using R packages to arrive at comparable end-results would introduce a lot of unnecessary complexity. In effect, whether to use R as an ETL backend depends on the nature of the project. In majority of the cases, building ETL pipelines using R will make sense if our project *already* uses R to undertake some analytical/statistical effort or there is a merit in brining R to do some statistical work. Likely, it is most efficient then to extend our R project by coding additional ETL using R than relaying on external tools to deliver data into R and outwith R.

# References

https://techterms.com/definition/programming_language

[^1]: Export Transform Load

[^2]: Colin Fay; [*An Introduction to Docker for R Users*](https://colinfay.me/docker-r-reproducibility/).

[^3]: An interesting implementation was offered by Tyler Cipriani in [his blog](https://tylercipriani.com/blog/2017/07/09/the-rsync-algorithm-in-python/).

[^4]: R package providing a convenient wrapper around `rsync` is available through the GitHub repo: [INWTlab/rsync](https://github.com/INWTlab/rsync).

[^5]: The answer the question on *Speed up rsync with Simultaneous/Concurrent File Transfers?* available [here](https://stackoverflow.com/a/25532027/1655567).
