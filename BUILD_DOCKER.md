# Building the ltc Docker Image

## The Issue You Encountered

If you see this error:
```
ERROR: dependency 'ggforce' is not available for package 'ltc'
```

This happens because Docker is using **cached layers from an old Dockerfile**. The old Dockerfile didn't install dependencies properly.

## Solution: Clear Cache and Rebuild

### Option 1: Using Docker Compose

```bash
# Clear cache and rebuild
docker-compose build --no-cache

# Start the container
docker-compose up -d
```

### Option 2: Using Docker CLI

```bash
# Remove old images
docker rmi ltc:test ltc:latest 2>/dev/null || true

# Build without cache
docker build --no-cache -t ltc:latest .

# Run it
docker run -d \
  --name ltc-rstudio \
  -p 8787:8787 \
  -e PASSWORD=ltc123 \
  ltc:latest
```

### Option 3: Clean Everything (Nuclear Option)

If you still have issues:

```bash
# Stop all ltc containers
docker stop $(docker ps -q --filter ancestor=ltc) 2>/dev/null || true

# Remove all ltc images
docker rmi $(docker images -q ltc) 2>/dev/null || true

# Prune build cache
docker builder prune -af

# Now rebuild
docker build -t ltc:latest .
```

## Verifying the Build

After building, test that ggforce is installed:

```bash
docker run --rm ltc:latest R -e "library(ggforce); packageVersion('ggforce')"
```

You should see the ggforce version number.

## Why This Happens

Docker caches each layer (step) in the Dockerfile. When you:
1. Build with an old Dockerfile → Docker caches those steps
2. Update the Dockerfile → Docker still uses old cached layers
3. Build again → Uses old cache, doesn't see new `install2.r` command

**Solution:** `--no-cache` forces Docker to rebuild everything from scratch.

## Quick Reference

| Command | Use When |
|---------|----------|
| `docker-compose build` | Normal rebuild (uses cache) |
| `docker-compose build --no-cache` | After Dockerfile changes |
| `docker builder prune -af` | Clear all Docker cache |
| `docker system prune -a` | Nuclear option - removes everything |

## GitHub Actions

The GitHub Actions workflow automatically builds without cache issues because it starts fresh every time. Once you push to GitHub, the workflow will build correctly!

## Testing Locally (When Docker is Running)

```bash
# Start Docker Desktop first!

# Build
docker-compose build --no-cache

# Start RStudio Server
docker-compose up -d

# Access http://localhost:8787
# Username: rstudio
# Password: ltc123

# Test ltc
# In RStudio, run:
library(ltc)
alger <- ltc("alger")
pltc(alger)

# Stop when done
docker-compose down
```

## If You Don't Want to Use Docker Locally

That's totally fine! The GitHub Actions will:
- ✅ Build the Docker image automatically
- ✅ Test all dependencies
- ✅ Verify ltc works correctly
- ✅ Generate build reports

Just push your changes and let GitHub Actions do the work!
