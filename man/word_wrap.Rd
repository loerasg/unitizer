% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/text.R
\name{word_wrap}
\alias{word_wrap}
\title{Wrap Lines at Words}
\usage{
word_wrap(x, width = getOption("width"), tolerance = 8L, hyphens = TRUE,
  unlist = TRUE)
}
\arguments{
\item{x}{character vector}

\item{width}{what width to wrap at}

\item{tolerance}{how much earlier than \code{width} we're allowed to wrap}

\item{hyphens}{whether to allow hyphenation}

\item{unlist}{logical(1L) if FALSE each element in \code{x} is returned as
an element of a list, otherwise one character vector is returned}
}
\value{
character vector, or list if \code{unlist} is FALSE
}
\description{
Similar to \code{\link{text_wrap}}, but only allows one length width and
breaks lines at words if possible.
}
\details{
Will attempt to hyphenate very crudely.
}
\keyword{internal}

