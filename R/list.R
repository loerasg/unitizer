#' @include class_unions.R

NULL

#' S4 Object To Implement Base List Methods
#'
#' The underlying assumption is that the `.items` slot is a list
#' (or an expression), and that that slot is the only slot for which
#' it's order and length are meaningful (i.e. there is no other list
#' or vector of same length as `.items` in a different slot that is
#' supposed to map to `.items`).  This last assumption allows us
#' to implement the subsetting operators in a meaninful manner.
#'
#' @keywords internal
#' @slot .items a list or expression
#' @slot .pointer integer, used for implementing iterators
#' @slot .seek.fwd logical used to track what direction iterators are going

setClass(
  "unitizerList",
  representation(.items="listOrExpression", .pointer="integer", .seek.fwd="logical"),
  prototype(.pointer=0L, .seek.fwd=TRUE)
)
# - Methods -------------------------------------------------------------------

#' Compute Number of Items in \code{`\link{unitizerList-class}`}
#'
#' @keywords internal

setMethod("length", "unitizerList", function(x) length(x@.items))

#' Subsetting Method for \code{`\link{unitizerList-class}`}
#'
#' @keywords internal

setMethod("[", signature(x="unitizerList", i="subIndex", j="missing", drop="missing"),
  function(x, i) {
    x@.items <- x@.items[i]
    x
} )
#' Subsetting Method for \code{`\link{unitizerList-class}`}
#'
#' @keywords internal

setMethod("[[", signature(x="unitizerList", i="subIndex"),
  function(x, i) {
    x@.items[[i]]
} )
#' Replace Method for \code{`\link{unitizerList-class}`}
#'
#' @name [<-,unitizerList,subIndex-method
#' @keywords internal

setReplaceMethod("[", signature(x="unitizerList", i="subIndex"),
  function(x, i, value) {
    pointer.reset <- (
      is.logical(i) && (lt <- sum(which(i) <= x@.pointer)) ||
      is.numeric(i) && (lt <- sum(floor(i) <= x@.pointer)) ||
      is.character(i) && (lt <- sum(match(i, names(x)) <= x@pointer))
    ) && is.null(value)
    x@.items[i] <- if(is(value, "unitizerList")) value@.items else value
    if(pointer.reset) x@.pointer <- x@.pointer - lt
    x
} )
#' Replace Method for \code{`\link{unitizerList-class}`}
#'
#' @name [[<-,unitizerList,subIndex-method
#' @keywords internal

setReplaceMethod("[[", signature(x="unitizerList", i="subIndex"),
  function(x, i, value) {
    pointer.reset <- (
      is.numeric(i) && floor(i[[1L]]) <= x@.pointer ||
      is.character(i) && match(i[[1L]], names(x)) <= x@pointer
    ) && is.null(value)
    x@.items[[i]] <- value
    if(pointer.reset) x@.pointer <- x@.pointer - 1L
    x
} )
#' Coerce to list by returning items
#' @keywords internal

setMethod("as.list", "unitizerList", function(x, ...) x@.items)

#' Coerce to expression by returning items coerced to expressions
#'
#' Really only meaningful for classes that implement the \code{`.items`}
#' slot as an expression, but works for others to the extent
#' \code{`.items`} contents are coercible to expressions
#'
#' @keywords internal

setMethod("as.expression", "unitizerList", function(x, ...) as.expression(x@.items, ...))

setGeneric("nextItem", function(x, ...) standardGeneric("nextItem"))

#' Iterate through items of a \code{`\link{unitizerList-class}`} Object
#'
#' Extraction process is a combination of steps:
#' \enumerate{
#'   \item Move Internal pointer with \code{`nextItem`} or \code{`prevItem`}
#'   \item Retrieve item \code{`getItem`}
#'   \item Check whether we're done iterating with \code{`done`}
#' }
#' \code{`done`} will return TRUE if the pointer is on either the
#' first or last entry depending on what direction you are iterating.
#' If you wish to iterate from the last item forward, you should either
#' \code{`reset`} with parameter \code{`reverse`} set to TRUE, or re-order
#' the items.
#'
#' @aliases nextItem,unitizerList-method, prevItem,unitizerList-method,
#'   getItem,unitizerList-method, reset,unitizerList-method, done,unitizerList-method
#' @keywords internal
#'
#' @param x a \code{`\link{unitizerList-class}`} object
#' @return \code{`\link{unitizerList-class}`} for \code{`getItem`},
#'   an item from the list, which could be anything

setMethod("nextItem", "unitizerList", valueClass="unitizerList",
  function(x) {
    x@.pointer <- x@.pointer + 1L
    x@.seek.fwd <- TRUE
    x
} )
setGeneric("prevItem", function(x, ...) standardGeneric("prevItem"))
setMethod("prevItem", "unitizerList", valueClass="unitizerList",
  function(x) {
    x@.pointer <- x@.pointer - 1L
    x@.seek.fwd <- FALSE
    x
} )
setGeneric("reset", function(x, ...) standardGeneric("reset"))
setMethod("reset", "unitizerList", valueClass="unitizerList",
  function(x, position=NULL) {
    if(
      !is.null(position) && (!is.character(position) ||
      !identical(length(position), 1L) || !(position %in% c("front", "back")))
    ) {
      stop("Argument `position` must be `NULL`, or \"front\" or \"back\"")
    }
    if(is.null(position)) position <- if(x@.seek.fwd) "front" else "back"
    if(identical(position, "front")) {
      x@.seek.fwd <- TRUE
      x@.pointer <- 0L
    } else if (identical(position, "back")) {
      x@.seek.fwd <- FALSE
      x@.pointer <- length(x) + 1L
    } else {
      stop("Logic Error; unexpected `position` argument")
    }
    x
} )
setGeneric("getItem", function(x, ...) standardGeneric("getItem"))
setMethod("getItem", "unitizerList",
  function(x) {
    if(!(x@.pointer %in% seq_along(x))) {
      if(x@.pointer %in% c(0L, length(x) + 1L)) {
        if(identical(x@.pointer, 0L) & x@.seek.fwd) {
          stop("Internal pointer for `x` not initialized; initialize with `nextItem`")
        } else if (identical(x@.pointer, length(x) + 1L) & !x@.seek.fwd) {
          stop("Internal pointer for `x` not initialized; initialize with `prevItem`")
        }
        stop(
          "Internal pointer for `x` outside of range for `x`; test for ",
          "this condition with `done`, or reset with `reset`"
        )
      } else {
        stop("Internal pointer for `x` is corrupted")
    } }
    x@.items[[x@.pointer]]
} )
setGeneric("done", function(x, ...) standardGeneric("done"))
setMethod("done", "unitizerList",
  function(x) {
    if(x@.seek.fwd & x@.pointer > length(x)) return(TRUE)
    else if (!x@.seek.fwd & identical(x@.pointer, 0L)) return(TRUE)
    FALSE
} )
#' @export

setGeneric("append")

#' Append To a \code{\link{unitizerList-class}} Object
#'
#' \code{values} is coerced to list or expression depending on
#' type of \code{x} \code{.items} slot.
#'
#' The resulting object is not tested for validity as this is too expensive
#' on a regular basis.  You should check validity with \code{validObject}
#'
#' @keywords internal
#' @param x the object to append to
#' @param values the object to append
#' @param after a subscript, after which the values are to be appended.

setMethod("append", c("unitizerList", "ANY"),
  function(x, values, after=length(x)) {
    attempt <- try(
      if(is.list(x@.items)) {
        values <- as.list(values)
      } else if (is.expression(x@.items)) {
        values <- as.expression(values)
      }
    )
    if(inherits(attempt, "try-error")) {
      stop("Unable to coerce argument `values` to appropriate type; see previous errors for details.")
    }
    if(!is.numeric(after) || !identical(length(after), 1L) || after < 0) {
      stop("Argument `after` must be a length 1 numeric greater than zero")
    }
    y <- x
    x <- x@.items
    y@.items <- callNextMethod()
    if(y@.pointer > after) y@.pointer <- y@.pointer + length(values)
    # validObject(y) # too expensive, commented
    y
} )
#' Concatenate to a \code{`\link{unitizerList-class}`}
#'
#' @keywords internal

setMethod("c", c("unitizerList"),
  function(x, ..., recursive=FALSE) {
    stop("This method is not implemented yet")
} )

#' Append Factors
#'
#' Note this is not related to \code{`\link{append,unitizerList,ANY-method}`}
#' except in as much as it is the same generic, so it just got thrown in here.
#'
#' @keywords internal

setMethod("append", c("factor", "factor"),
  function(x, values, after=length(x)) {
    if(!identical(attributes(x), attributes(values))) NextMethod()
    if(
      !is.numeric(after) || round(after) != after || length(after) != 1L ||
      after > length(x) || after < 0L
    ) stop("Argument after must be integer like between 0 and length(x)")
    if(!length(values)) return(x)
    len.x <- length(x)
    length(x) <- length(x) + length(values)
    if(after < len.x) {
      x[(after + 1L + length(values)):length(x)] <- x[(after + 1L):(len.x)]
    }
    x[(after + 1L):(after + length(values))] <- values
    x
  }
)
