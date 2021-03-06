#' @include item.R
#' @include item.sub.R
#' @include class_unions.R

NULL

#' Contains Representation For a Section of Tests
#'
#' \code{unitizerSectionExpression-class} contains the actual expressions that
#' belong to the section, whereas \code{unitizerSection-class} only contains
#' the meta data.  The latter objects are used within \code{\link{unitizer-class}},
#' whereas the former is really just a temporary object until we can generate
#' the latter.
#'
#' \code{unitizerSectionNA-class} is a specialized section for tests that actually
#' don't have a section (removed tests that are nonetheless chosen to be kept
#' by user in interactive environment)
#'
#' @keywords internal
#' @aliases unitizerSectionExpression-class unitizerSectionNA-class
#' @slot title 1 lenght character, the name of the section
#' @slot details character vector containing additional info on the section
#' @slot compare functions to compare the various aspects of a \code{\link{unitizerItem-class}}
#' @slot length tracks size of the section

setClass(
  "unitizerSection",
  representation(
    title="character",
    details="character",
    compare="unitizerItemTestsFuns",
    length="integer",
    parent="integer"
  ),
  prototype(parent=NA_integer_, length=0L),
  validity=function(object) {
    if(length(object@title) != 1L) return("slot `@title` must be length 1")
    if(length(object@length) != 1L | object@length < 0L) {
      return("slot `@length` must be length 1 and >= 0")
    }
    if(length(object@parent) != 1L) return("slot `@parent` must be a 1 length integer")
  }
)
setMethod("initialize", "unitizerSection",
  function(.Object, ...) {
    if(!("title" %in% (dot.names <- names(list(...))))) {
      return(callNextMethod(.Object, title="<untitled>", ...))
    } else if(is.null(list(...)$title)) {
      return(do.call(callNextMethod, c(list(.Object, title="<untitled>"), list(...)[dot.names != "title"])))
    }
    callNextMethod()
} )
setClass(
  "unitizerSectionNA", contains="unitizerSection",
  prototype=list(
    title="<untitled>", details="Dummy section for section-less tests."
  )
)
setClass("unitizerSectionExpression", contains="unitizerList",
  representation(
    title="characterOrNULL",
    details="character",
    compare="unitizerItemTestsFuns"
  )
)
setClassUnion("unitizerSectionExpressionOrExpression", c("unitizerSectionExpression", "unitizerSection", "expression"))

#' Compute Length of a \code{\link{unitizerSection-class}}
#'
#' @keywords internal
#' @param x a \code{unitizerSection} object

setMethod("length", "unitizerSection", function(x) x@length)

#' Define a \code{unitizer} Section
#'
#' The purpose of \code{unitizer} sections is to allow the user to tag a
#' group of test expressions with meta information as well as to modify the
#' comparison functions used when determining whether the newly evaluated
#' values match the reference values.
#'
#' @section Comparison Functions:
#'
#' \code{unitizer} will compare values as well as some side effects from
#' the test expression evaluation.  If you wish to modify the comparison function
#' for the value of the test expressions then all you need to do is pass your
#' comparison function as the \code{compare} argument.
#'
#' If a comparison function signals a condition (e.g. throws a warning) the
#' test will not be evaluated, so make sure that your function does not signal
#' conditions unless it is genuinely failing.
#'
#' If you wish to modify the comparison functions for the side effects of test
#' evaluation (e.g. screen output or conditions), then you need to pass a
#' \code{\link{unitizerItemTestsFuns-class}} object intialized with the
#' appropriate functions (see example).
#'
#' Make sure your comparison functions are available to \code{\link{unitize}}.
#' Comparisons will be evaluated in the environment of the test.  By default
#' \code{\link{unitize}} runs tests in environments that are not children to
#' the global environment, so functions defined there will not be automatically
#' available.  You can either specify the function in the test file before the
#' section that uses it, or change the base environment tests are evaluated in with
#' \code{unitize(..., par.env)}, or make sure that the package that
#' contains your function is loaded within the test script.
#'
#' @section Nested Sections:
#'
#' It is possible to have nested sections, but titles, etc. are ignored.  The
#' only effect of nested sections is to allow you to change the comparison
#' functions for a portion of the outermost \code{unitizer_sect}.
#'
#' @note if you want to modify the functions used to compare conditions,
#' keep in mind that the conditions are stored in lists, so your function
#' must loop through the lists and compare conditions pairwise.  By default
#' \code{unitizer} uses the \code{all.equal} method for S4 class
#' \code{conditionList}.
#'
#' @note \code{untizer} does not account for sections when matching new and
#' reference tests.  All tests will be displayed as per the section they belong
#' to in the newest version of the test file, irrespective of what section they
#' were in when the tests were last run.
#'
#' @note Calls to \code{unitizer_sect} should be at the top level of your test
#' script, or nested within other \code{unitizer_sect}s (see "Nested Sections").
#' Do not expect code like \code{(untizer_sect(..., ...))} or
#' \code{{unitizer_sect(..., ...)}} or \code{fun(unitizer_sect(..., ...))} to
#' work.
#'
#' @export
#' @param title character 1 length title for the section, can be omitted
#'   though if you do omit it you will have to refer to the subsequent
#'   arguments by name (i.e. \code{unitizer_sect(expr=...)})
#' @param expr test expression(s), most commonly a call to \code{{}} with
#'   several calls inside (see examples)
#' @param details character more detailed description of what the purpose
#'   of the section is; currently this doesn't do anything.
#' @param compare a function or a \code{\link{unitizerItemTestsFuns-class}}
#'   object
#' @examples
#' unitizer_sect("Custom Tests", {
#'   my_fun("a", FALSE)
#'   my_fun(845, TRUE)
#' })
#' unitizer_sect("Compare With Identical",
#'   {
#'     my_exact_fun(6L)
#'     my_exact_fun("hello")
#'   },
#'   compare=identical
#' )
#' unitizer_sect("Compare With Identical",
#'   {
#'     my_exact_fun(6L)
#'     my_exact_fun("hello")
#'   },
#'   compare=identical
#' )
#' unitizer_sect("Compare With Identical For Screen Output",
#'   {
#'     my_exact_fun(6L)
#'     my_exact_fun("hello")
#'   },
#'   compare=unitizerItemTestsFuns(value=identical, output=identical)
#' )
unitizer_sect <- function(title=NULL, expr=expression(), details=character(), compare=new("unitizerItemTestsFuns")) {
  if(!is(compare, "unitizerItemTestsFuns") & !is.function(compare)) stop("Argument `compare` must be \"unitizerItemTestsFuns\" or a function")
  if(!is.character(details)) stop("Argument `details` must be character")
  if(!is.null(title) && (!is.character(title) || length(title) != 1L)) stop("Argument `title` must be a 1 length character vector.")
  exp.sub <- substitute(expr)
  if(is.call(exp.sub) && is.symbol(exp.sub[[1L]])) expr <- exp.sub
  if(is.call(expr)) {
    if(identical(expr.sub.eval <- eval(expr[[1L]], parent.frame()), base::"{")) {
      expr <- do.call(expression, as.list(expr[-1L]))
    } else if (identical(expr.sub.eval, base::expression)) {
      expr <- eval(expr, parent.frame())
    }
  }
  if (!is.expression(expr)) {
    stop("Argument `expr` must be an expression, or an unevaluated call that evaluates to an expression or `{`.")
  }
  if(!is(compare, "unitizerItemTestsFuns")) {
    if(is.function(compare)) {
      compare <- try(
        new(
          "unitizerItemTestsFuns",
          value=new("unitizerItemTestFun", fun=compare, fun.name=deparse_fun(substitute(compare)))
      ) )
      if(inherits(compare, "try-error")) {
        stop("Problem with provided function for argument `compare`; see previous errors for details")
      }
    } else stop("Logic Error: contact package maintainer.")
  }
  if(length(expr) < 1L) {
    warning("`unitizer_sect` \"", strtrunc(title, 15), "\" is empty.")
    return(NULL)
  }
  attempt <- try(new("unitizerSectionExpression", title=title, .items=expr, details=details, compare=compare))
  if(inherits(attempt, "try-error")) stop("Failed instantiating `unitizerSection`; see previous error for details.")
  attempt
}
