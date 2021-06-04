inverse <- function(x, type, low = NULL, high = NULL) {
  
  if (type == "zero_centered") {
    x <- -x
  } else if (type == "bounded") {
    if (is.null(low)) {
      low <- min(x, na.rm = T)
    }
    if (is.null(high)) {
      high <- max(x, na.rm = T)
    }
    x <- -x + (high - low) + 2*(low)
  } else {
    stop("Unknown type")
  }
  x
}