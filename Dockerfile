# syntax=docker/dockerfile:1.4

# Stage 2: Final build environment
FROM --platform=linux/amd64 rocker/tidyverse

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gzip \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libpng-dev \
    libssl-dev libxml2-dev \
    libuv1-dev \
    libxt-dev \
    pandoc \
    python3 \
    python3-pip \
    python3-venv \
    tar \
    texlive-bibtex-extra \
    texlive-fonts-recommended \
    texlive-latex-base \
    texlive-latex-extra \
    zlib1g-dev \
    wget \
    openjdk-11-jdk \
    libmagick++-dev \
    libmagickwand-dev \
    libmagickcore-dev \
    imagemagick \
    libqpdf-dev \
    libpoppler-cpp-dev

# Clean installed packages from apt cache
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use all cores when building packages
ENV MAKEFLAGS="-j$(nproc)"

# Install Quarto
RUN wget -q https://quarto.org/download/latest/quarto-linux-amd64.deb && \
    dpkg -i quarto-linux-amd64.deb && \
    rm quarto-linux-amd64.deb

# Optional: confirm
RUN quarto --version

# Verify pandoc installation
RUN pandoc --version

# Install virtualenv for reticulate
RUN python3 -m venv /opt/blogpost-env && \
    /opt/blogpost-env/bin/pip install --upgrade pip && \
    /opt/blogpost-env/bin/pip install numpy
ENV RETICULATE_PYTHON=/opt/blogpost-env/bin/python

# Install Hugo v0.148.1 (Extended)
RUN wget -qO- https://github.com/gohugoio/hugo/releases/download/v0.148.1/hugo_extended_0.148.1_Linux-64bit.tar.gz \
    | tar -xz --wildcards --no-anchored -C /usr/local/bin hugo

# Set default repo to Posit Package Manager
RUN echo 'options(repos = c(RSPM = "https://packagemanager.posit.co/cran/latest"))' >> /usr/local/lib/R/etc/Rprofile.site

# Install R packages one per layer by increasing dependency complexity
# Install R packages
RUN Rscript -e "install.packages(c( \
    'argparse', \
    'bookdown', \
    'DBI', \
    'glue', \
    'httpuv', \
    'kableExtra', \
    'knitr', \
    'magick', \
    'miniUI', \
    'pdftools', \
    'quarto', \
    'reticulate', \
    'rmarkdown', \
    'rstudioapi', \
    'servr', \
    'sparklyr', \
    'tufte'))"

# Check problematic packages
RUN Rscript -e "stopifnot('pdftools' %in% rownames(installed.packages()))"

# Install spark
RUN Rscript -e "sparklyr::spark_install(version = '3.5.6')"

# Create working directory
WORKDIR /site

# Expose port for blogdown::serve_site()
EXPOSE 4321

# Enable citeproc support
RUN echo 'options(rmarkdown.pandoc.args = c("--citeproc"))' >> /usr/local/lib/R/etc/Rprofile.site

# Facilitate new post creation
RUN Rscript -e "install.packages('argparse')"
COPY new_post.R /usr/local/bin/new_post.R
RUN chmod +x /usr/local/bin/new_post.R

# Script to rebuild blog
COPY blog_build.R /usr/local/bin/blog_build.R
RUN chmod +x /usr/local/bin/blog_build.R

# Script to preview blog
COPY blog_preview.R /usr/local/bin/blog_preview.R
RUN chmod +x /usr/local/bin/blog_preview.R

CMD ["R"]
