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
    quarto::quarto_render(f, execute = TRUE, output_format = "hugo-md")
  } else {
    message("▶ Skipping ", f, " (index.md exists)")
  }
}

# Also render root index.Rmd if it exists
root_index <- "index.Rmd"
if (file.exists(root_index)) {
  message("▶ Rendering root ", root_index)
  quarto::quarto_render(root_index, output_format = "hugo-md", execute = TRUE)
}

message("▶ Building site with Hugo...")
system("hugo -D --cleanDestinationDir")
