#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(quarto)
})

message("▶ Rendering individual .Rmd files in content/post with Quarto...")
rmd_files <- list.files("content/post", pattern = "\\.Rmd$", full.names = TRUE, recursive = TRUE)
for (f in rmd_files) {
  message("▶ Rendering ", f)
  quarto::quarto_render(f, output_format = "gfm", execute = TRUE)
}

message("▶ Building site with Hugo...")
system("hugo -D")
