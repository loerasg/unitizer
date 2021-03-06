% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/exec.R
\name{eval_user_exp}
\alias{eval_user_exp}
\alias{user_exp_display}
\alias{user_exp_handle}
\title{Utility function to evaluate user expressions}
\usage{
eval_user_exp(unitizerUSEREXP, env)

user_exp_display(value, env, expr)

user_exp_handle(expr, env, print.mode, expr.raw)
}
\arguments{
\item{unitizerUSEREXP}{an expression to evaluate}

\item{env}{environment the environment to evaluate the expression in}
}
\value{
TBD
}
\description{
A fair bit of manipulation required to ensure the trace and calls associated
with conditions are reasonable.  This should be mostly correct except for the
notable exception of top-level conditions, which will be recorded correctly,
but for which the \code{std.err()} output will show the
\code{withVisible(...)} call.  Doesn't seem to be a straightforward way of
capturing that short of tossing the \code{stderr} and spoofing the message.

Evaluate Print/Show of an Object
}
\seealso{
exec, unitizer_prompt
}
\keyword{internal}

