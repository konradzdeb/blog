---
title: Inserting Data into Partitioned Table
author: Konrad Zdeb
date: '2021-02-26'
slug: inserting-data-into-partitioned-table
categories:
  - how-to
  - example
tags:
  - R
  - Spark
references:
- id: costa2019
  title: Evaluating partitioning and bucketing strategies for Hive‐based Big Data Warehousing systems
  author:
  - family: Costa
    given: Eduarda
  - family: Costa
    given: Carlos
  - family: Santos
    given: Maribel Yasmina
  container-title: Journal of Big Data
  volume: 6
  URL: 'https://doi.org/10.1186/s40537-019-0196-1'
  DOI: 10.1186/s40537-019-0196-1
  issue: 34
  publisher: Nature Publishing Group
  page: 1-38
  type: article-journal
  issued:
    year: 2019
    month: 4
---

# Rationale

Maintaining partitioned Hive tables is a frequent practice in a business. Properly structured tables are conducive to achieving robust performance through speeding up query execution (see Costa, Costa, and Santos 2019). Frequent use cases pertain to creating tables with hierarchical partition structure. In context of a data that is refreshed daily, the frequently utilised partition structure reflects years, months and dates.

## Creating partitioned table

In HiveQL we would create the table with the following structure using the syntax below. In order to keep the development tidy, I’m creating a separate database on Hive which I will use for the purpose of creating tables for this article.

``` sql
-- Initially test database is created to keep the development tidy
CREATE DATABASE blog COMMENT 'Blog article samples, can be deleted.';
-- Example table is created
CREATE TABLE blog.sample_partitioned_table (
		value_column_a FLOAT 	COMMENT 'Column will hold 4-byte number', 
		value_column_b DOUBLE 	COMMENT '8-byte double precision', 
		value_column_c CHAR(1) 	COMMENT 'Fixed length varchar') 
	COMMENT 'Sample partitioned table stored as text file' 
	PARTITIONED BY (
		part_year SMALLINT 	COMMENT 'Data load year, partition', 
		part_month TINYINT 	COMMENT 'Data load month, partition',
		part_day TINYINT	COMMENT 'Data load day, partition')
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY '\t'
	LINES TERMINATED BY '\n'
	STORED AS TEXTFILE;
```

The code snippet above achieves the following:

- Table `sample_partitioned_table` is created within newly created database `blog`.
- Three value columns are defined of `FLOAT`, `DOUBLE` and `CHAR(1)` types. Hive offers fairly rich set of data types and it’s worth to study [the official documentation](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Types) in order to ensure that selection of types is optimal considering the data we want to feed into the table. If we don’t have this clarity the wise solution may be to use more common types likes `INT`.
- The `blog.sample_partitioned_table` is stored as a text file with lines separated by tabs and rows separated with end line.
- The table defines theree columns used to partition the data, `tinyint` type is suitable to hold values from -127 to 127 so it can be used to store day and month values, `smallint` type holds values from -32,768 to 32,768 so it’s suitable for storing annual data.

For more substantial tables with frequent usage further consideration should be given to the [Hive file formats](https://cwiki.apache.org/confluence/display/Hive/FileFormats) as well as wider storage strategy aspects.

## Inserting data from R

Inserting data using packages like [`glue`](https://glue.tidyverse.org/) in R is trivial, and enables us to deliver highly readable code that will be easy to maintain.

### Sample data

In an actual production setting, we would expect that our run will generate a data consistent with the table structure that should be saved as one of partitions. A common scenario could reflect summary events data generated for specific day, in business that structure would be frequently used to develop views on periodical business activity. For the purpose of example, I’m generating some sample data in R.

``` r
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(lubridate))
# Generating two months of data
dates <- seq.Date(
    from = as.Date("01-01-2010", format = "%d-%m-%Y"),
    to = as.Date("28-02-2010", format = "%d-%m-%Y"),
    by = "day"
)
# Each data will contain two rows of values corresponding to the column types
# that were previously defined in Hive
sample_data <- map_dfr(.x = dates, ~ tibble(val_a = runif(2),
                                            val_b = runif(2),
                                            val_c = sample(letters, 2),
                                            update_year = year(.x),
                                            update_month = month(.x),
                                            update_day = day(.x)))
```

The created data looks as follows:

``` r
head(sample_data)
```

    ## # A tibble: 6 × 6
    ##    val_a val_b val_c update_year update_month update_day
    ##    <dbl> <dbl> <chr>       <dbl>        <dbl>      <int>
    ## 1 0.116  0.545 m            2010            1          1
    ## 2 0.560  0.542 j            2010            1          1
    ## 3 0.321  0.799 w            2010            1          2
    ## 4 0.0179 0.525 e            2010            1          2
    ## 5 0.273  0.787 x            2010            1          3
    ## 6 0.789  0.526 g            2010            1          3

Following the successful creation of the dummy data we are in position to easily leverage the desired data structure. Using the [`sparklyr`](https://spark.rstudio.com) package I’m creating a local connection.

``` r
suppressPackageStartupMessages(library(sparklyr))
sc <- spark_connect(master = "local")
```

For the purpose of the article I’ve also executed the provided-above HiveQL via Spark to ensure accessibility to data structures that would be structurally equivalent, ensuring smooth execution of the example code. Naturally, in a production setting, we would seldom look to create new Hive schema from an R script layer. Similarly, core tables storing results would be usually established outside regular production processes.

    ## <DBISparkResult>
    ##   SQL  DROP TABLE IF EXISTS blog.sample_partitioned_table
    ##   ROWS Fetched: 0 [complete]
    ##        Changed: 0

    ## <DBISparkResult>
    ##   SQL  DROP DATABASE IF EXISTS blog
    ##   ROWS Fetched: 0 [complete]
    ##        Changed: 0

``` r
res_DBI_data <- DBI::dbSendQuery(sc, "CREATE DATABASE blog COMMENT 'Blog article samples,                                           can be deleted.'")
res_DBI_tble <- DBI::dbSendQuery(sc, "CREATE TABLE blog.sample_partitioned_table (
		value_column_a FLOAT 	COMMENT 'Column will hold 4-byte number', 
		value_column_b DOUBLE 	COMMENT '8-byte double precision', 
		value_column_c CHAR(1) 	COMMENT 'Fixed length varchar') 
	COMMENT 'Sample partitioned table stored as text file' 
	PARTITIONED BY (
		part_year SMALLINT 	COMMENT 'Data load year, partition', 
		part_month TINYINT 	COMMENT 'Data load month, partition',
		part_day TINYINT	COMMENT 'Data load day, partition')
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY '\t'
	LINES TERMINATED BY '\n'
	STORED AS TEXTFILE")
```

### Insert mechanism

Where the DBI package comes extremely handy is in inserting data into partitions. In context of our sample data we will want to populate every single partition with the respective modelling results. Courtesy of `map_dfc` function the “results” are available in one table but the proposed method can be easily modified and applied across other object structures, like lists. As a first step we will be looking to copy the existing sample data into Spark.

``` r
tbl_sprk <- copy_to(sc, sample_data, "spark_sample_data")
```

In Spark our RDD is visible as `spark_sample_data` we will be looking to use that table in order to insert our partition elements into permanent storage.

``` r
suppressPackageStartupMessages(library(DBI))
suppressPackageStartupMessages(library(glue))
res_pmap <- pmap(
    .l = select(sample_data, update_year, update_month, update_day),
    .f = ~ DBI::dbSendQuery(sc, glue("INSERT INTO TABLE blog.sample_partitioned_table
                                     PARTITION (part_year={..1},
                                                part_month={..2},
                                                part_day={..3})
                                     SELECT val_a, val_b, val_c
				     	FROM spark_sample_data
                                     	WHERE update_year={..1} AND
                                        update_month={..2} AND
                                        update_day={..3}")))
```

Let’s unpack the code below. Our key goals are:
\* Our aim is to populate *partitions* in our permanent Hive table `blog.sample_partitioned_table`, hence the statement `INSERT INTO TABLE blog.sample_partitioned_table`
\* We are working with some modelling/analytical data that currently sits in our Spark session as `spark_sample_data` and we want for the relevant results in the data to land in the prescribed partitions on Spark

What happens in the process is as follows:
1. We are generating a list of vectors with partitions identifiers to iterate over. As I’ve created this sample data in the current session in memory I can just refer to those items using `select` I would do that in the following manner `select(sample_data, update_year, update_month, update_day)`
2. I’m interested in iterating over each column simultaneously and `pmap` function is excellent for that. Using `~` notation offered in `pmap` I will be looking to refer to first object as `..1` to the second as `..2` and so on.
3. Glue package is used to insert strings with partitions identifier into the respective partition names.
4. `SELECT` runs on *spark RDD* and also uses partition identifiers to get only subset of the data we are interested in and insert that subset into the desired partition.

### Results

Following the operation above we can now explore the populated storage table. Sparklyr’s [`sdf_num_partitions`](https://spark.rstudio.com/reference/) can be used to get a number of existing partitions. Tibble’s [`glimpse`](https://tibble.tidyverse.org/reference/glimpse.html) can be used against the Spark data to get the preview of the created table.

``` r
tbl_perm <- tbl(sc, "blog.sample_partitioned_table")
sdf_num_partitions(tbl_perm)
```

    ## [1] 118

``` r
glimpse(tbl_perm)
```

    ## Rows: ??
    ## Columns: 6
    ## Database: spark_connection
    ## $ value_column_a <dbl> 0.025499297, 0.892674923, 0.025499297, 0.892674923, 0.3…
    ## $ value_column_b <dbl> 0.70547767, 0.04573262, 0.70547767, 0.04573262, 0.08341…
    ## $ value_column_c <chr> "s", "l", "s", "l", "d", "m", "d", "m", "j", "o", "j", …
    ## $ part_year      <int> 2010, 2010, 2010, 2010, 2010, 2010, 2010, 2010, 2010, 2…
    ## $ part_month     <int> 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1…
    ## $ part_day       <int> 31, 31, 31, 31, 25, 25, 25, 25, 12, 12, 12, 12, 23, 23,…

# Summary

Convenient and flexible functions facilitating string manipulations available in R make metaprogramming[^1] in R easy. Generating and manipulating Hive statements as strings may not be the most efficient strategy in the light of the API’s offered via `sparklyr` or `dbplyr`. Neverthless is possible to spot instances where R code makes those coding challenges partiuclary easy to solution and also to maintain.

# References

<div id="refs" class="references csl-bib-body hanging-indent" entry-spacing="0">

<div id="ref-costa2019" class="csl-entry">

Costa, Eduarda, Carlos Costa, and Maribel Yasmina Santos. 2019. “Evaluating Partitioning and Bucketing Strategies for Hive‐based Big Data Warehousing Systems.” *Journal of Big Data* 6 (34): 1–38. <https://doi.org/10.1186/s40537-019-0196-1>.

</div>

</div>

[^1]: Metaprogramming is a programming paradigm that treats other programming programs as data. In business, a BI setting metaprogramming is frequently used to generate efficiencies in routine data handling tasks, such as automating generation of SQL statements for importing data.
