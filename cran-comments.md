## Submission — ltc 0.4.0

This is a minor feature update to `ltc` (version 0.3.0 is currently on CRAN).

## Changes in this version (0.4.0)

* New palette `casa_natal`.
* New function `ltc_cvd()` previews a palette under the three main types of
  colour-vision deficiency.
* Added a pkgdown website; redesigned the overview figure and added example
  charts. These assets live in the repository only and are excluded from the
  build, so the package tarball remains small.
* Documentation updates.
* One co-author (previously listed with role "aut") has been removed from the
  Authors@R field at the maintainer's request, as their earlier contribution is
  no longer part of the package.

## Test environments

* local: macOS, R 4.5.1 (2025-06-13)
* win-builder (devel and release): to be tested before submission
* R-hub: to be tested before submission

## R CMD check results

0 errors | 0 warnings | 1 note

The single NOTE is local only:

* "Skipping checking HTML validation: 'tidy' doesn't look like recent enough
  HTML Tidy." This reflects the HTML Tidy version on the local machine, not a
  problem in the package documentation; CRAN's systems validate the HTML.

## Downstream dependencies

There are currently no downstream dependencies for this package.
