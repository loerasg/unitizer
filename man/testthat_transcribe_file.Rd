% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/translate.R
\name{testthat_transcribe_file}
\alias{testthat_transcribe_file}
\title{Transcribes a \code{testtaht} File Into \code{unitizer} Format}
\usage{
testthat_transcribe_file(file.name, target.dir = file.path(dirname(file.name),
  "..", "unitizer"), keep.testthat.call = TRUE, prompt = "always", ...)
}
\arguments{
\item{file.name}{a path to the \code{testthat} test file to convert}

\item{target.dir}{the directory to create the \code{unitizer} test file and
test store in; for \code{testthat_translate_file} only: if NULL will return
as a character vector what the contents of the translated file would have
been instead of writing the file}

\item{keep.testthat.call}{whether to preserve the \code{testthat} call that
was converted, as a comment}

\item{prompt}{character(1L): \itemize{
  \item "always" to always prompt before writing new files
  \item "overwrite" only prompt if existing file is about to be overwritten
  \item "never" never prompt
}}

\item{...}{params to pass on to \code{testthat_translate_name}}
}
\description{
Internal use only, required so we can ensure the parse succeeded because of
possible parse-deparse issues independent of running \code{unitize}, since
\code{unitize} cannot be run inside a \code{tryCatch} block.
}
\keyword{internal}

