#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(quarto)
})

# More explicit environment variable handling
full_build <- Sys.getenv("FULL_BUILD", unset = "1")
is_full <- !tolower(full_build) %in% c("0", "false")

message("▶ Environment FULL_BUILD=", full_build)
message("▶ Build mode: ", if(is_full) "FULL" else "INCREMENTAL")
message("▶ Rendering individual .Rmd files in content/post with Quarto...")
rmd_files <- list.files("content/post", pattern = "\\.Rmd$", full.names = TRUE, recursive = TRUE)

for (f in rmd_files) {
  md_file <- file.path(dirname(f), "index.md")
  if (is_full || !file.exists(md_file)) {
    message("▶ Rendering ", f)
    quarto::quarto_render(f, output_format = "gfm", execute = TRUE)
  } else {
    message("▶ Skipping ", f, " (index.md exists)")
  }
}

message("▶ Building site with Hugo...")
system("hugo -D --cleanDestinationDir")
