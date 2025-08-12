# Why regex is not fuzzy matching
Konrad Zdeb
2021-06-29

Recently, I cam across an interesting discussion on StackOverflow[^1]
pertaining to approach to fuzzy matching tables in R. Good answer
contributed by one of the most resilient and excellent contributors to
whom I owe a lot of thanks for help suggested relying on regular
expression, combining this with basic sting removal and transformations
like `toupper` to deterministically match the tables. The solution
solved the problem and was accepted.

# So what’s wrong…

With this particular problem/solution pair, there is absolutely nothing
wrong. On numerous occasions I have seen people running
`UPPER(REGEXP_REPLACE( my_value, '[[:space:]]', '' ))` only so later
someone can realise, that actually now they need
`REGEXP_REPLACE(COLUMN,'[^[:ascii:]],'')` only for someone else to offer
`SELECT REGEXP_REPLACE(COLUMN,'[^' || CHR(1) || '-' || CHR(127) || '],'')`[^2].
Those are all good solutions that solve the particular challenge but
they (very) seldom stand the test of time.

The *real* problem is in not finding the most robust approach but
deciding how the challenge is being approached from a priority
perspective. Those of us who endlessly twist the regex so they arrive at
something resembling the regex below, which was actually created to
match email addresses[^3], aspire to match *deterministically* at any
price and frequently are destined to fail, especially when working with
data reflecting human-input.

``` r
^(?:(?!.*?[.]{2})[a-zA-Z0-9](?:[a-zA-Z0-9.+!%-]{1,64}|)|\"[a-zA-Z0-9.+!% -]{1,64}\")@[a-zA-Z0-9][a-zA-Z0-9.-]+(.[a-z]{2,}|.[0-9]{1,})$
```

The nature of the regex matching is source of the problem. Regex-based
matching will always result a binary outcome, strings will match or not.
By the very definition **regex-based matching is not fuzzy matching.**

## Pardigm shift … (just becasuse wee don’t menion this phrase often enough)

When you attempt to match things fuzzily you are signing up to a few
assumptions:

1)  Your matching reflects certain probabilistic assumptions or in other
    words, *your match is not expected to be 100% accurate.*
2)  There is no “one right” method to do the matching, ways of
    calculating string distances may be less or more suitable for a
    given problem. Computationally expensive procedures may yield
    excellent result but prove impractical from the implementation
    perspective, and so on
3)  Whereas for regex there is clear direction of improvement: it can be
    (almost) always tweaked more to account for one more ‘edge case’ the
    improvement direction

# Example

Generating example that show inefficiency of regex when contrasted with
string matching approach. The most obvious example is the one that will
show mismatches on misspelled words. Let’s consider the following
example. Two data sets contain a set of strings reflecting car
manufactures, as shown below.

``` r
data_A <- tibble::tribble(
    ~ manufacturer, ~ price,
    "Ford Focus", 100,
    "Ford Mondeo", 120,
    "  Ford Corsa", 30,
    "Mercedes W205 C-Class", 90,
    "Mecedes X156 GLA-Class", 10
)

data_B <- tibble::tribble(
    ~ manufacturer, ~ subjective_rating,
    "Frod", "B",
    "mercedes" , "A"
)
```

Let’s say that we want to bring the `subjective_rating` column to the
`data_A`. The first, common sense would to match on the actual
`manufacturer`. The one could be tempted to get the first word from the
manufacturer column and use it for matching. We could attempt to match
using only brand name. For that purpose the most straightforward
implementation would be to delete everything after space. As shown
bellow, the first problem we are seeing that `" Ford Corsa"` was deleted
as it starts with space.

``` r
suppressPackageStartupMessages(library("tidyverse"))
data_A |> 
    mutate(manufacturer = str_remove(manufacturer, "\\s.*")) |> 
    left_join(data_B)
```

    Joining with `by = join_by(manufacturer)`

    # A tibble: 5 × 3
      manufacturer price subjective_rating
      <chr>        <dbl> <chr>            
    1 "Ford"         100 <NA>             
    2 "Ford"         120 <NA>             
    3 ""              30 <NA>             
    4 "Mercedes"      90 <NA>             
    5 "Mecedes"       10 <NA>             

We could solve that problem by running `trimws` or `str_trim` first,
let’s do that. For better visibility the step is inserted as a separate
call but we could easily wrap that call in the existing transformation.
However, the results are still unsatisfactory.

``` r
suppressPackageStartupMessages(library("tidyverse"))
data_A |> 
    mutate(manufacturer = str_trim(manufacturer),
           manufacturer = str_remove(manufacturer, "\\s.*")) |> 
    left_join(data_B)
```

    Joining with `by = join_by(manufacturer)`

    # A tibble: 5 × 3
      manufacturer price subjective_rating
      <chr>        <dbl> <chr>            
    1 Ford           100 <NA>             
    2 Ford           120 <NA>             
    3 Ford            30 <NA>             
    4 Mercedes        90 <NA>             
    5 Mecedes         10 <NA>             

The potential next step could be addressing the upper case / lower case
challenge. After doing this, the records start to match but the approach
proves inefficient. We can tweak our matching further using regex. If we
want to match directly on a regex column we can use `regex_left_join`
from the `fuzzyjoin` package. At this point the tables start to match
but the overall conclusions are quite disappointing, we are facing
either endlessly tweaking our string through regex or standalone
transformation to arrive at a suitable match if we want to progress in
that direction. We are also exposing ourselves to a risk that added row
with misspelled name will break that logic. In an actual production
environment there is a risk that substantial inflow of data will break
our logic for a significant number of records.

``` r
suppressPackageStartupMessages(library("tidyverse"))
data_A |> 
    mutate(manufacturer = str_trim(manufacturer),
           manufacturer = str_to_lower(manufacturer),
           manufacturer = str_remove(manufacturer, "\\s.*")) |> 
    fuzzyjoin::regex_left_join(data_B, by = "manufacturer")
```

    # A tibble: 5 × 4
      manufacturer.x price manufacturer.y subjective_rating
      <chr>          <dbl> <chr>          <chr>            
    1 ford             100 <NA>           <NA>             
    2 ford             120 <NA>           <NA>             
    3 ford              30 <NA>           <NA>             
    4 mercedes          90 mercedes       A                
    5 mecedes           10 <NA>           <NA>             

## A “pragmatic programmer” approach …

At this junction it’s beneficial revise our initial assumptions. After
working with this trivial sample data we can conclude that:

- Those tables have no right to match in 100%, if we code for every
  single opportunity there is a strong chance that new data will through
  this approach through the window by introducing new spelling mistakes,
  spaces and so forth…

- There is no consistency in mistakes, the data may contain superfluous
  spaces or odd capitalisation, we can’t form a assumption on what is
  the main problem to fix here.

A solution to this challenge would be to approach the matching problem
from a probabilistic perspective. A first option would be to generate a
function assessing how dissimilar are our strings. Jaro-Winkler string
distance is a metric continuously used in computer science and
computational statistics assessing how distant are give strings. The
comparator package offers a convenient implementation of that function.
For this example, I’m leaving the default option and forcing only
ignoring strings.

``` r
library("comparator")
jw <- JaroWinkler(ignore_case = TRUE)
jw("Mercedes", "mecedes")
```

    [1] 0.9666667

The function returns distance between two strings and, expectedly, `jw`
will return quite a high score for for common spelling mistakes. The
score for dissimilar words will be much lower.

``` r
jw("Mercedes", "opel corsa zxc")
```

    [1] 0.5119048

We can attempt to implement the function in our matching further
leverage the functions available in a `fuzzyjoin` package. The
`fuzzy_left_join` requires for the matching function to require a
boolean output so we can wrap actual results in an anonymous
function[^4]

``` r
fuzzyjoin::fuzzy_left_join(x = data_A, y = data_B, by = "manufacturer",
                           match_fun = function(x, y) { jw(x, y) >= 0.65}
                           )
```

    # A tibble: 5 × 4
      manufacturer.x           price manufacturer.y subjective_rating
      <chr>                    <dbl> <chr>          <chr>            
    1 "Ford Focus"               100 Frod           B                
    2 "Ford Mondeo"              120 Frod           B                
    3 "  Ford Corsa"              30 Frod           B                
    4 "Mercedes W205 C-Class"     90 mercedes       A                
    5 "Mecedes X156 GLA-Class"    10 mercedes       A                

Without any string transformations we are achieving *reasonable* match.
The key word is here is *reasonable.* The proposed approach only makes
sense if we agree that we are not looking for a perfect match but we are
willing to accept reasonably good output.

# So what

First be honest with what do you need, can you live with a few
mismatched records? If you are building data to predict trends
reflecting substantial populations the likely answer is *yes,* if you
are building data set to email personalised marketing communication to
existing customers the likely answer is *no.*

[^1]: SO discussion on: [*Fuzzy Join with Partial String Match in
    R*](https://stackoverflow.com/a/68182330/1655567)

[^2]: The example originations from SO discussion on removing non-ASCII
    characters; this is actually [one of the better
    answerers](https://Stack%20Overflow.com/a/18234629/1655567) offered.

[^3]: This is taken from a [closed
    question](https://stackoverflow.com/a/50914014/1655567) validating
    email addresses; the SO hosts [another, longer,
    discussion](https://stackoverflow.com/q/201323/1655567) that offers
    detailed discussion on regex approach to validating emails

[^4]: Anonymous function have simply no name and usually are used within
    other calls, like `sapply`, etc. For a discussion refer to the
    [article on
    R-Bloggers.](https://www.r-bloggers.com/2017/09/anonymous-functions-in-r-and-python/)
