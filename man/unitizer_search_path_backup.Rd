% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/zeroenv.R
\name{unitizer_search_path_backup}
\alias{unitizer_search_path_backup}
\title{Search Path Back-up}
\usage{
unitizer_search_path_backup()
}
\value{
character the search path
}
\description{
Holds the state of the search path before `unitizer` to serve as a back-up
in case the search path manipulation functions are unable to restore the
search path to it's original value.
}

