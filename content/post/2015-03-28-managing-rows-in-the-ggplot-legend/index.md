---
title: Managing rows in the ggplot legend
author: Konrad
date: '2015-03-28'
slug: managing-rows-in-the-ggplot-legend
categories:
  - how-to
tags:
  - R
  - ggplot2
---

After developing the Shiny App sourcing live labour market data from NOMIS. I wanted to accommodate a convenient way of managing rows in the legend. In particular, I wanted to account for the situation where end-user may select a number of geographies that will only conveniently fit into two or more rows. After transposing the data to long format, guessing the number of elements in the legend is relatively simple as it will correspond to the number of unique geographies passed via the subset command.


``` r
g <- guide_legend(title = "Geography", title.position = 'top',
nrow = (if(length(unique(dta.chrt$GEOGRAPHY_NAME)) > 5) 2
else 1),
title.theme = element_text(size = 14, face = 'bold', angle = 360))
```

For a small number of values we can conveniently get a small legend with one row:

![Small legend with one row](images/screen-shot-2015-03-28-at-10-32-52.png)

whereas legend with a vast number of geographies is conveniently resized:

![Bigger legend with two rows](images/screen-shot-2015-03-28-at-10-33-09.png)
