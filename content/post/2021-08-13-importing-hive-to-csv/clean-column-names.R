#' Clean Column Names
#'
#' Arbitrary set of rules transforming string so passed results are consistent
#'   with HiveQL rules on syntactically correct column names.
#'
#' @details Manual replacements are useful for when we may be dealing with
#'   columns where automatic application of rules is not desired. For instance
#'   if our intention is to rename column "Super Important Column" to
#'   "to_delete" we would use the \code{manual_replacement} argument to implement
#'   that change.
#'
#' @param x A character vector with column names to transform
#' @param lowercase_currency_names A logic, defaults to \code{FALSE}, whether to
#'   convert the currency names to lower-case.
#' @param manual_replacement A named vector defining manual replacement for
#'   column names can be of format c("Super Important Column" = "to_delete) or
#'   c("3" = "to_delete") for column positions.
#' @param remove_words A character vector with words we like to remove,
#'   defaults to commonly occuring words in column name like "per, by, for"
#'
#' @return A character vector
#'
#' @export
#'
#' @examples
#' dirty_col_names <- c("Date of Birth", "12-important-column",
#'   "14-crucial-column", " user    inputs", "price in (£)")
#' clean_column_names(x = dirty_col_names)
clean_column_names <- function(x, lowercase_currency_names = FALSE,
                               manual_replacement = NULL,
                               remove_words = c("per", "by", "for")) {
  x <- stringi::stri_trim_both(x)
  x <- stringi::stri_trans_tolower(x)
  x <- stringi::stri_replace_all_regex(x, "^[^a-z]*", "") # Column name should start with a letter
  x <- stringi::stri_replace_all_charclass(x, "\\p{WHITE_SPACE}", "_")
  x <- stringi::stri_replace_all_regex(x, "^[^a-z]*", "") # Column name should start with a letter
  x <-
  x
}


dirty_col_names <- c("Date of Birth", "12-important-column",
   "14-crucial-column", " user inputs", "price in (£)")
print(clean_column_names(x = dirty_col_names))
