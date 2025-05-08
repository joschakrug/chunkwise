test_that("chunkwise reading works", {
  str <- paste(replicate(5, "ab cd ef"), 1:5) |> paste(collapse = "\n")

  outfile <- tempfile()
  write(str, outfile)

  str_reconstructed <- ""
  handler <- function(chunk_text) {
    str_reconstructed <<- paste0(str_reconstructed, chunk_text)
  }

  read_chunkwise(outfile, handler, chunk_size = 2, repeat_header = FALSE)

  expect_equal(
    paste0(str, "\n"),  # account for the fact that read_chunkwise terminates
                        # each chunk with an \n
    str_reconstructed
  )
})
