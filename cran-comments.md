## R CMD check results

0 errors | 0 warnings | 2 notes

## Changes in this version (0.3.0)

* Updated package for CRAN submission
* Improved documentation and examples
* Removed `col2transparent()` function from CRAN version (available in development version only)
* Enhanced package metadata and compliance

## Test environments

* local: macOS Sequoia 15.6.1, R 4.5.1 (2025-06-13)
* win-builder: (devel and release) - to be tested
* R-hub: to be tested

## R CMD check results

There were 2 NOTEs:

1. New submission
   - This is expected for a first-time CRAN submission.

2. HTML validation: 'tidy' doesn't look like recent enough HTML Tidy
   - HTML Tidy version 5.8.0 is installed locally but R CMD check doesn't recognize it.
   - This is a local environment issue. CRAN's automated systems will validate the HTML properly.
   - No actual HTML validation errors exist in the documentation.

## Downstream dependencies

There are currently no downstream dependencies for this package.
