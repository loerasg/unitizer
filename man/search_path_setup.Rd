% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/zeroenv.R
\name{search_path_setup}
\alias{search_path_setup}
\title{Set-up Shims and Other Stuff for Search Path Manip}
\usage{
search_path_setup()
}
\value{
logical(1L) TRUE indicates success
}
\description{
Here we shim by \code{`trace`}ing the \code{`libary/require/attach/detach`}
functions and recording each run of those functions that modifies the
search path with enough information to restore the search path later.
}
\keyword{internal}

