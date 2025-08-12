# syntax=docker/dockerfile:1.4

# Use official Spark image as base
FROM --platform=linux/amd64 apache/spark:3.5.6 as spark

# Stage 2: Final build environment
FROM --platform=linux/amd64 rocker/tidyverse

# Copy Spark from official image
COPY --from=spark /opt/spark /opt/spark

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
    python3-dev \
    python3-numpy \
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
    libpoppler-cpp-dev \
    docker.io

# Install Swift with proper permissions and setup
RUN SWIFT_VERSION=5.10.1 \
    && wget https://download.swift.org/swift-$SWIFT_VERSION-release/ubuntu2004/swift-$SWIFT_VERSION-RELEASE/swift-$SWIFT_VERSION-RELEASE-ubuntu20.04.tar.gz \
    && tar -xzf swift-$SWIFT_VERSION-RELEASE-ubuntu20.04.tar.gz \
    && mv swift-$SWIFT_VERSION-RELEASE-ubuntu20.04 /usr/share/swift \
    && rm swift-$SWIFT_VERSION-RELEASE-ubuntu20.04.tar.gz \
    && chmod -R 755 /usr/share/swift

# Set Swift environment variables
ENV PATH="/usr/share/swift/usr/bin:$PATH"
ENV SWIFT_HOME="/usr/share/swift"
ENV LD_LIBRARY_PATH="/usr/share/swift/usr/lib/swift/linux:$LD_LIBRARY_PATH"

# Install Swift dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libatomic1 \
    libcurl4 \
    libxml2 \
    libedit2 \
    libsqlite3-0 \
    libc6-dev \
    binutils \
    libgcc-9-dev \
    libstdc++-9-dev \
    libpython3.8 \
    tzdata \
    pkg-config \
    libncurses6 \
    libncurses-dev \
    && rm -rf /var/lib/apt/lists/*

# Verify Swift installation (REPL not supported in headless Docker)
RUN swift --version

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

# Reticulate configuration
ENV RETICULATE_PYTHON=/usr/bin/python3

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
    'tufte', \
    'fuzzyjoin' \
    ))"
RUN Rscript -e "install.packages(c( \
    'comparator' \
    , 'wakefield' \
    , 'formatR' \
    ))"

# Check problematic packages
RUN Rscript -e "stopifnot('pdftools' %in% rownames(installed.packages()))"

# Tell Sparklyr to use the installed Spark
ENV SPARK_HOME=/opt/spark

# Add permissions fix
RUN chmod -R 755 /opt/spark

# Verify Swift installation (REPL not supported in headless Docker)
RUN swift --version

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

# Reticulate configuration
ENV RETICULATE_PYTHON=/usr/bin/python3

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
    'tufte', \
    'fuzzyjoin' \
    ))"
RUN Rscript -e "install.packages(c( \
    'comparator' \
    , 'wakefield' \
    , 'formatR' \
    ))"

# Check problematic packages
RUN Rscript -e "stopifnot('pdftools' %in% rownames(installed.packages()))"

# Tell Sparklyr to use the installed Spark
ENV SPARK_HOME=/opt/spark

# Add permissions fix
RUN chmod -R 755 /opt/spark

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
