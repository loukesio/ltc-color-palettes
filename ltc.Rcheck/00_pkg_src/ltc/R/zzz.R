# This code is to inform R that the listed names are intentionally global variables
# to prevent 'no visible binding for global variable' warnings during R CMD check
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c("palette_name", "x1", "x2","x3","x4","y1","y2","y3","y4" ,"x","y","xvals","yvals","text")) # Add other variables as needed
}
