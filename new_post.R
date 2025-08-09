#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(argparse)
  library(fs)
  library(stringr)
})

`%||%` <- function(a, b) if (!is.null(a)) a else b

parser <- ArgumentParser(description = "Create a new Quarto blog post")

parser$add_argument("-t", "--title", required = TRUE, help = "Post title")
parser$add_argument("-a", "--author", help = "Author name")
parser$add_argument("-c", "--categories", help = "Comma-separated list of categories")
parser$add_argument("-g", "--tags", help = "Comma-separated list of tags")
parser$add_argument("-s", "--slug", help = "Slug (URL-friendly title)")
parser$add_argument("-d", "--subdir", default = "posts", help = "Subdirectory (default: posts)")
parser$add_argument("-o", "--open", action = "store_true", help = "Open in editor")

args <- parser$parse_args()

# Determine slug and post directory
slug <- args$slug %||% str_replace_all(tolower(args$title), "[^a-z0-9]+", "-")
date <- Sys.Date()
post_dir <- path(args$subdir, paste0(date, "-", slug))

dir_create(post_dir)

post_file <- path(post_dir, "index.qmd")

# Write front matter
yaml_lines <- c(
  "---",
  paste0("title: \"", args$title, "\""),
  paste0("date: ", date)
)

if (!is.null(args$author)) {
  yaml_lines <- c(yaml_lines, paste0("author: \"", args$author, "\""))
}
if (!is.null(args$categories)) {
  cats <- str_split(args$categories, ",")[[1]]
  yaml_lines <- c(yaml_lines, "categories:", paste0("  - ", trimws(cats)))
}
if (!is.null(args$tags)) {
  tags <- str_split(args$tags, ",")[[1]]
  yaml_lines <- c(yaml_lines, "tags:", paste0("  - ", trimws(tags)))
}

yaml_lines <- c(yaml_lines, "---", "")

write_lines(yaml_lines, post_file)

if (args$open) {
  system2("open", post_file)
}
