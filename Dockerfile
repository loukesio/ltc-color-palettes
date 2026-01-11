# Use rocker/tidyverse as base image (includes R, RStudio Server, and tidyverse packages)
# Using R 4.5 to match your development environment
FROM rocker/tidyverse:4.5

# Metadata
LABEL maintainer="Loukas Theodosiou <theodosiou@evolbio.mpg.de>" \
      description="Docker image for ltc: Collection of Artistic and Nature-Inspired Color Palettes" \
      version="0.3.0"

# Set working directory
WORKDIR /home/rstudio

# Install ltc dependencies from CRAN
# These will be automatically installed when installing ltc, but we install them
# explicitly here to take advantage of Docker layer caching
RUN install2.r --error --skipinstalled \
    dplyr \
    ggplot2 \
    ggforce \
    colorspace \
    && rm -rf /tmp/downloaded_packages

# Copy the package source code into the container
COPY . /home/rstudio/ltc

# Build and install the ltc package from source
RUN R CMD build /home/rstudio/ltc \
    && R CMD INSTALL ltc_*.tar.gz \
    && rm ltc_*.tar.gz

# Optional: Copy example scripts to a convenient location
RUN mkdir -p /home/rstudio/examples

# Set proper permissions for RStudio user
RUN chown -R rstudio:rstudio /home/rstudio

# Expose port 8787 for RStudio Server
EXPOSE 8787

# The base image already has CMD to start RStudio Server
# Default user: rstudio, password: rstudio
# To change password, set environment variable PASSWORD when running container

