# convert_rmd_to_md.R

rmd_files <- list.files(
  path = "content/post",
  pattern = "^index\\.Rmd$",
  recursive = TRUE,
  full.names = TRUE
)

message("Found ", length(rmd_files), " Rmd files.")

for (f in rmd_files) {
  post_dir <- dirname(f)
  message("Rendering: ", f)

  tryCatch({
    rmarkdown::render(
      input = f,
      output_format = "md_document",
      output_file = "index.md",
      output_dir = post_dir,
      quiet = TRUE
    )
    message("✔ Rendered ", f)

    # Optional cleanup
    unlink(f)
    unlink(file.path(post_dir, "index.Rmd.lock~"))
    unlink(file.path(post_dir, "index.html"))
    unlink(file.path(post_dir, "index.knit.md~"))
  }, error = function(e) {
    message("❌ Failed: ", f, " — ", e$message)
  })
}
