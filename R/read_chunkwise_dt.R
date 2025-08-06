#' Read in a text file as a data.table, chunk by chunk
#' 
#' This function is a wrapper around the [read_chunkwise()] function that reads
#' in a text file chunk-by-chunk as a `data.table`.
#'
#' Crucially, a custom `filter` function can be provided to perform arbitrary
#' transformations on each chunk before appending it to the full data.table.
#' Each chunk is passed to the `filter` function as a `data.table` object. The
#' `filter` function can either return a modified copy of the `data.table` (if
#' `copy = TRUE`) or modify this `data.table` in place (if `copy = FALSE`).
#' 
#' Be aware that, due to limitations of the `data.table` interface, assignment
#' by reference is only possible for column transformations, not for filtering
#' of rows (see \link[data.table]{set}).
#'
#' @param file Path to the text file to read
#' @param filter Filter function (defaults to `identity`)
#' @param copy Set to `FALSE` if the `filter` function modifies the provided
#'   `data.table` chunk in place instead of returning a modified copy of the
#'   chunk (defaults to `TRUE`)
#' @param sep Column separator in the text file (defaults to `,`)
#' @param ... Other arguments are passed through to [read_chunkwise()]
#' @return A `data.table` generated from the data in the text file
#' 
#' @example examples/read_chunkwise_dt_example.R
#'
#' @export
read_chunkwise_dt <- function(
    file, filter = identity, copy = TRUE, sep = ",", ...
  ) {
  chunks <- list()
  n_chunk <- 1

  chunk_handler <- function(chunk_text) {
    chunk_dt <- data.table::fread(
      text = chunk_text, sep = sep, header = TRUE
    )
    if (copy) {
      chunk_dt <- filter(chunk_dt)
    }
    else {
      filter(chunk_dt)
    }
    chunks[[n_chunk]] <<- chunk_dt
    n_chunk <<- n_chunk + 1
  }

  read_chunkwise(
    file, chunk_handler, ...
  )
  data.table::rbindlist(chunks, use.names = FALSE)
}

# according to DeepSeek, this is what I need to add to any R file in the project
# in order to ensure roxygen2 works correctly with the Rcpp module

#' 