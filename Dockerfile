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
    && rm -rf /var/lib/apt/lists/*

# Use all cores when building packages
ENV MAKEFLAGS="-j$(nproc)"

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
RUN Rscript -e "install.packages('miniUI')"
RUN Rscript -e "install.packages('knitr')"
RUN Rscript -e "install.packages('servr')"
RUN Rscript -e "install.packages('rmarkdown')"
RUN Rscript -e "install.packages('bookdown')"
RUN Rscript -e "install.packages('tufte')"
RUN Rscript -e "install.packages('reticulate')"
RUN Rscript -e "install.packages('rstudioapi')"
RUN Rscript -e "install.packages('httpuv')"
RUN Rscript -e "install.packages('DBI')"
RUN Rscript -e "install.packages('glue')"
# Finally install blogdown
RUN Rscript -e "install.packages('blogdown'); stopifnot(requireNamespace('blogdown', quietly = TRUE))"

# Install spark and sparklyr
RUN Rscript -e "install.packages('sparklyr'); sparklyr::spark_install(version = '3.5.6')"

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

CMD ["R"]