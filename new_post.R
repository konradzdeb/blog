#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(argparse)
  library(blogdown)
})

`%||%` <- function(a, b) if (!is.null(a)) a else b

parser <- ArgumentParser(description = "Create a new blogdown post")

parser$add_argument("-t", "--title", required = TRUE, help = "Post title")
parser$add_argument("-a", "--author", help = "Author name (default: blogdown.author option)")
parser$add_argument("-c", "--categories", help = "Comma-separated list of categories")
parser$add_argument("-g", "--tags", help = "Comma-separated list of tags")
parser$add_argument("-s", "--slug", help = "Slug (URL-friendly title)")
parser$add_argument("-x", "--ext", default = ".Rmd", help = "File extension [.md/.Rmd] (default: .Rmd)")
parser$add_argument("-d", "--subdir", default = "post", help = "Subdirectory (default: post)")
parser$add_argument("-o", "--open", action = "store_true", help = "Open in editor")

args <- parser$parse_args()

blogdown::new_post(
  title      = args$title,
  author     = args$author %||% getOption("blogdown.author"),
  categories = if (!is.null(args$categories)) strsplit(args$categories, ",")[[1]] else NULL,
  tags       = if (!is.null(args$tags)) strsplit(args$tags, ",")[[1]] else NULL,
  slug       = args$slug,
  ext        = args$ext,
  subdir     = args$subdir,
  open       = args$open
)