## R CMD check results

0 errors | 0 warnings | 4 notes

* This is a new release.

* NOTE: "checking for hidden files and directories"
  - Found .github directory. This has been added to .Rbuildignore.

* NOTE: "checking top-level files"
  - Files 'README.md' or 'NEWS.md' cannot be checked without 'pandoc' being installed.
  - This is a local environment issue and will not affect the package build on CRAN.

* NOTE: "checking HTML version of manual"
  - Skipping checking HTML validation: 'tidy' doesn't look like recent enough HTML Tidy.
  - This is a local environment issue and will not affect the package build on CRAN.

* NOTE: "checking CRAN incoming feasibility"
  - This is a new submission, so this NOTE is expected.

## Test environments

* local macOS install, R 4.5.1
* GitHub Actions (windows-latest, macOS-latest, ubuntu-latest), R release and devel

## Downstream dependencies

There are currently no downstream dependencies for this package.
