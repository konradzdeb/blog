quarto::quarto_render(".", execute = TRUE)
system("hugo server --bind 0.0.0.0 -p 4321 -D")