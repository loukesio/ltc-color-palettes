# Docker Setup for ltc

This Docker image provides a complete R environment with RStudio Server and the `ltc` package pre-installed, based on the [rocker/tidyverse](https://hub.docker.com/r/rocker/tidyverse) image.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system
- [Docker Compose](https://docs.docker.com/compose/install/) (optional, but recommended)

## Quick Start

### Option 1: Using Docker Compose (Recommended)

1. **Build and start the container:**
   ```bash
   docker-compose up -d
   ```

2. **Access RStudio Server:**
   - Open your browser and go to: http://localhost:8787
   - Username: `rstudio`
   - Password: `ltc123` (can be changed in `docker-compose.yml`)

3. **Start using ltc:**
   ```r
   library(ltc)

   # List available palettes
   names(palettes)

   # Select and display a palette
   alger <- ltc("alger")
   pltc(alger)

   # Use in a plot
   pal <- ltc("maya", 5, "continuous")
   library(ggplot2)
   ggplot(diamonds, aes(price, fill = cut)) +
     geom_histogram(binwidth = 500) +
     scale_fill_manual(values = pal)
   ```

4. **Stop the container:**
   ```bash
   docker-compose down
   ```

### Option 2: Using Docker CLI

1. **Build the image:**
   ```bash
   docker build -t ltc:latest .
   ```

2. **Run the container:**
   ```bash
   docker run -d \
     --name ltc-rstudio \
     -p 8787:8787 \
     -e PASSWORD=ltc123 \
     -v $(pwd)/workspace:/home/rstudio/workspace \
     ltc:latest
   ```

3. **Access RStudio Server:**
   - Go to http://localhost:8787
   - Login with username `rstudio` and password `ltc123`

4. **Stop and remove the container:**
   ```bash
   docker stop ltc-rstudio
   docker rm ltc-rstudio
   ```

### Option 3: R Console Only (No RStudio)

If you just need R console without the web interface:

```bash
# Using docker-compose
docker-compose run --rm r-console

# Or using Docker CLI
docker run -it --rm ltc:latest R
```

## Features

- **R 4.5:** Matches the development environment
- **RStudio Server:** Web-based IDE accessible via browser
- **Tidyverse packages:** Pre-installed (dplyr, ggplot2, tidyr, etc.)
- **ltc package:** Pre-installed from source with all color palettes
- **Persistent workspace:** Files in `./workspace` are preserved between sessions

## Color Palettes Available

The ltc package includes 24 artistic and nature-inspired color palettes:

- **Artist-inspired:** paloma, maya, dora, ploen, olga, mterese, gaby, franscoise, fernande, sylvie
- **Research:** crbhits, expevo
- **Art works:** minou, kiss, hat, reading, alger
- **Utility:** ten_colors, trio1-4, heatmap, pantone23

## Customization

### Change RStudio Password

Edit the `PASSWORD` environment variable in `docker-compose.yml`:

```yaml
environment:
  - PASSWORD=your_secure_password
```

### Disable Authentication (Local Use Only)

Add this to the environment section in `docker-compose.yml`:

```yaml
environment:
  - DISABLE_AUTH=true
```

### Mount Additional Directories

Add volume mounts in `docker-compose.yml`:

```yaml
volumes:
  - ./workspace:/home/rstudio/workspace
  - ./data:/home/rstudio/data
  - ./plots:/home/rstudio/plots
```

## GitHub Actions - Automated Builds

This repository includes automated Docker builds and R CMD checks via GitHub Actions!

### What happens automatically:

✅ **Docker Build** (every push to main/master):
- Docker image is built and tested
- ltc installation is verified
- Palette selection and dependencies are tested
- Build report is generated

✅ **R CMD check** (every push/PR):
- **Windows** (latest, R release)
- **macOS** (latest, R release)
- **Ubuntu** (latest, R devel/release/oldrel-1)
- Comprehensive testing across 5 environments
- Ensures package works on all major platforms

### View Results

Check the [Actions tab](https://github.com/loukesio/ltc-color-palettes/actions) to see build and test results.

### Status Badges

Add these to your README.md:

```markdown
[![Docker Build](https://github.com/loukesio/ltc-color-palettes/actions/workflows/docker-build.yml/badge.svg)](https://github.com/loukesio/ltc-color-palettes/actions/workflows/docker-build.yml)
[![R-CMD-check](https://github.com/loukesio/ltc-color-palettes/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/loukesio/ltc-color-palettes/actions/workflows/R-CMD-check.yml)
```

## Workspace Directory

The `workspace` directory is automatically created and mounted to `/home/rstudio/workspace` in the container. Any files you save here will persist after the container is stopped.

## Example Usage in Container

Once inside RStudio Server:

```r
# Load the package
library(ltc)

# Explore palettes
names(palettes)
info$palette_name  # See palette names and descriptions

# Basic usage
paloma <- ltc("paloma")
pltc(paloma)  # Visualize as color bar

# Plot as sinusoidal curves
plts(paloma)

# Plot as a bird
bird(paloma)

# Use in ggplot
library(ggplot2)
pal <- ltc("heatmap", 10, "continuous")
ggplot(data.frame(x = rnorm(1e4), y = rnorm(1e4)), aes(x = x, y = y)) +
  geom_hex() +
  coord_fixed() +
  scale_fill_gradientn(colours = pal) +
  theme_void()

# Save your plot
ggsave("workspace/my_palette_plot.png", width = 8, height = 6)
```

## Troubleshooting

### Port 8787 is already in use

Change the port mapping in `docker-compose.yml`:

```yaml
ports:
  - "8888:8787"  # Access RStudio at localhost:8888
```

### Permission issues with mounted volumes

On Linux, you may need to set proper ownership:

```bash
sudo chown -R 1000:1000 workspace/
```

### Container won't start

Check logs:
```bash
docker-compose logs rstudio
```

### Rebuild after changes

```bash
docker-compose build --no-cache
docker-compose up -d
```

## Development

### Testing Local Changes

If you're developing ltc and want to test changes:

1. Make changes to the R code
2. Rebuild the container:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

### Accessing R Package Check Logs

```bash
docker run --rm -v $(pwd):/pkg ltc:latest \
  R CMD check --as-cran /pkg
```

## Additional Resources

- [Rocker Project Documentation](https://rocker-project.org/)
- [Docker Documentation](https://docs.docker.com/)
- [RStudio Server Documentation](https://docs.posit.co/ide/server-pro/)
- [ltc GitHub Repository](https://github.com/loukesio/ltc-color-palettes)

## Support

For issues related to:
- **ltc package:** https://github.com/loukesio/ltc-color-palettes/issues
- **Docker image:** https://github.com/loukesio/ltc-color-palettes/issues
- **Rocker base image:** https://github.com/rocker-org/rocker-versioned2/issues
