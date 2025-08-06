test_that("chunkwise data frame reading works", {
  dt <- data.table::data.table(
    a = replicate(200, "abc"),
    n = 1:200
  )

  outfile <- tempfile()
  data.table::fwrite(dt, file = outfile)

  dt_reconstructed <- read_chunkwise_dt(
    outfile, chunk_size = 7
  )

  expect_equal(dt, dt_reconstructed)
})

test_that("chunkwise data frame filtering (by copy) works", {
  dt <- data.table::data.table(
    a = replicate(200, "abc"),
    n = 1:200
  )

  outfile <- tempfile()
  data.table::fwrite(dt, file = outfile)

  chunk_filter <- function(chunk_dt) {
    chunk_dt[, b := n * 2]
    chunk_dt[, n := NULL]
    chunk_dt <- chunk_dt[b %% 5 == 0,]

    chunk_dt
  }

  dt_reconstructed <- read_chunkwise_dt(
    outfile, chunk_size = 7, filter = chunk_filter
  )

  expect_equal(chunk_filter(dt), dt_reconstructed)
})

test_that("chunkwise data frame transformation (by reference) works", {
  dt <- data.table::data.table(
    a = replicate(200, "abc"),
    n = 1:200
  )

  outfile <- tempfile()
  data.table::fwrite(dt, file = outfile)

  chunk_transform <- function(chunk_dt) {
    chunk_dt[, c := paste(a, a, sep = ",")]
    chunk_dt[, a := NULL]
  }

  dt_reconstructed <- read_chunkwise_dt(
    outfile, chunk_size = 7, filter = chunk_transform
  )

  chunk_transform(dt)
  expect_equal(dt, dt_reconstructed)
})
