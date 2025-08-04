Is there a merit for a three-way operator in R?

# Background

In C++20 revision added “spaceship operator”, [which is defined as
follows](https://en.cppreference.com/w/cpp/language/operator_comparison#Three-way_comparison):

    (a <=> b) < 0  # if lhs < rhs
    (a <=> b) > 0  # if lhs > rhs
    (a <=> b) == 0 # if lhs and rhs are equal/equivalent.

# R implementation

The behaviour can be achieved in R in multiple ways. A one
straightforward approach would involve making use of the `ifelse`
statement

## `ifelse` implementation

Basic approach would involve comparing the two figures and respectively
returning `-1` or `1` consistently with the definition above.

    a <- 1
    b <- 2
    ifelse(a < b, -1, 1)

    ## [1] -1

The shortcoming of this approach is that adhering to `(a <=> b) == 0`
condition would require extra `ifelse` statement.

    a <- 1
    b <- 1
    ifelse(a < b, -1, 1)

    ## [1] 1

The result above is wrong as consistently with the definition the
operator should return zero. This can be achieved with the following
solution.

    a <- 1
    b <- 1
    ifelse(a == b, 0, ifelse(a < b, -1, 1))

    ## [1] 0

    a <- 1
    b <- 2
    ifelse(a == b, 0, ifelse(a < b, -1, 1))

    ## [1] -1

    a <- 2
    b <- 1
    ifelse(a == b, 0, ifelse(a < b, -1, 1))

    ## [1] 1

### Challenges

There are few challenges pertaining to the implementation above. The one
that is particularly stark pertains to type conversion. For `a` being
`"a"` R returns `TRUE`.

    a <- "a"
    b <- 1
    ifelse(a > b, TRUE, FALSE)

    ## [1] TRUE

This is due to the implementation of comparison on atomic vectors. As
stated in `?Comparison` documentation:

> If the two arguments are atomic vectors of different types, one is
> coerced to the type of the other, the (decreasing) order of precedence
> being character, complex, numeric, integer, logical and raw.

This behaviour may be confusing, especially to those expecting to
comparison operators to act as strict equality.[1] Developers au fait
with JavaScript may not be surprised by R’s behaviours as they will be
familiar with `==` and `===` where former compares variables undertaking
type conversation and latter checks type of the variable. In R `===` can
be obtained with use of `?identical`.

The other interesting challenge is concerned with vectorisation. For
vectors of unequal sizes we get a warning but also an answer.

    a <- c(2,2,2)
    b <- c(1,1)
    ifelse(a == b, 0, ifelse(a < b, -1, 1))

    ## Warning in a == b: longer object length is not a multiple of shorter object
    ## length

    ## Warning in a < b: longer object length is not a multiple of shorter object
    ## length

    ## [1] 1 1 1

Finally, the syntax of our nested `ifelse` statement is not useful. We
could wrap the whole thing in a simple function

    three_way <- function(a, b) {
        ifelse(a == b, 0, ifelse(a < b, -1, 1))
    }

Still this is not as useful as calling this operator in-line
`lhs <=> rhs` in C++ fashion.

## Infix implementation

Fairly neat solution can be obtained with use of infix operator. Infix
operators are common and frequently used in R. For instance

    5 + 2

    ## [1] 7

statement is equivalent to

    `+`(5,2)

    ## [1] 7

User-defined infix functions can be created by creating functions that
start and end with `%`. Let’s assume that we want to achieve the
following objectives:

- Control for types of compared vectors
- Control for size of compared vectors
- Have control over the outcome:
  - Staying strict with the provided C++ implementation
  - Modifying this behaviour, by for instance, returning the bigger
    object

This can be quickly achieved using the following implementation.

    `%<=>%` <- function(lhs, rhs) {

        if (typeof(lhs) != typeof(rhs)) {
            warning("Left and right hand operators are not of identical types.")
        }

        # Single comparison function
        f_check <- function(lhs, rhs) {
            if (lhs > rhs) {
                lhs
            } else if (lhs < rhs) {
                rhs
            } else if (lhs == rhs) {
                0
            }
        }

        # Run on each element of vector
        purrr::modify2(.x = lhs, .y = rhs, .f = f_check)
    }

In effect, the results obtained through the first set of `ifelse`
statements can be easily achieved using `max`. The only - albeit very
minor - advantage of the implementation is that it would be easily to
modify it to behave in a manner consistent with the original
implementation. Instead of returning `lhs` or `rhs` we would look to
return `-1` and `1` as in the example below.

    `%<=>%` <- function(lhs, rhs) {

        if (typeof(lhs) != typeof(rhs)) {
            warning("Left and right hand operators are not of identical types.")
        }

        # Single comparison function
        f_check <- function(lhs, rhs) {
            if (lhs > rhs) {
                1
            } else if (lhs < rhs) {
                -1
            } else if (lhs == rhs) {
                0
            }
        }

        # Run on each element of vector
        purrr::modify2(.x = lhs, .y = rhs, .f = f_check)
    }

### Vectorisation and type checking

I like
[`purrr::modify2`](https://purrr.tidyverse.org/reference/modify.html)
due to consistent error messages it gives. Let’s say that we mistakenly
compare vectors that are of different lengths. This would result in a
following error message.

    `%<=>%` <- function(lhs, rhs) {

        if (typeof(lhs) != typeof(rhs)) {
            warning("Left and right hand operators are not of identical types.")
        }

        # Single comparison function
        f_check <- function(lhs, rhs) {
            if (lhs > rhs) {
                1
            } else if (lhs < rhs) {
                -1
            } else if (lhs == rhs) {
                0
            }
        }

        # Run on each element of a vector
        purrr::modify2(.x = lhs, .y = rhs, .f = f_check)
    }

    a <- c(1,2,3)
    b <- c(1,2)
    a %<=>% b

    ## Error in `map2()`:
    ## ! Can't recycle `.x` (size 3) to match `.y` (size 2).

# Summary

The need for the actual `%<=>%` is scant as `ifelse` and `max`
efficiently fulfil that role. Nevertheless, creating spaceship operator
in R is trivial and demonstrates flexibility of the language very well.
I have a similar implementation in a package that I use to store
[`KEmisc`](https://github.com/konradzdeb/KEmisc/blob/master/R/threeway.R)
package that I use to store, trivial, handy functions.

[1] Relevant [StackOverflow
discussion](https://stackoverflow.com/q/14932015/1655567) on the
subject.
