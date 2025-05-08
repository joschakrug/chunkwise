test_that("chunkwise data frame reading works", {
  dt <- data.table::data.table(
    a = replicate(200, "abc"),
    n = 1:200
  )

  outfile <- tempfile()
  write.csv(dt, file = outfile, row.names = FALSE)

  dt_reconstructed <- read_chunkwise_dt(
    outfile, chunk_size = 7
  )

  expect_equal(dt, dt_reconstructed)
})
