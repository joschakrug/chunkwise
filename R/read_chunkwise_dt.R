#' Read in a large tabular text file as a data.table, chunk by chunk
#'
#' Crucially, a custom `filter` function can be provided to perform arbitrary
#' transformations on each chunk before appending it to the full data.table.
#'
#' @param file Path to the text file to read
#' @param filter Filter function (defaults to `identity`)
#' @param ... Parameters passed through to `read_chunkwise`
#' @return A `data.table` generated from the data in the text file
#'
#' @export
read_chunkwise_dt <- function(
    file, filter = identity, sep = ",", ...
  ) {
  chunks <- list()
  n_chunk <- 1

  chunk_handler <- function(chunk_text) {
    chunk_dt <- data.table::fread(
      text = chunk_text, sep = sep, header = TRUE
    )
    chunk_dt <- filter(chunk_dt)
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