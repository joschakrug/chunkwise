dt <- data.table::data.table(
    a = replicate(1000, "abc"),
    n = 1:1000
)

outfile <- tempfile()
data.table::fwrite(dt, file = outfile)

# read chunkwise, filtering by copy

chunk_filter <- function(chunk_dt) {
  # modifying the original chunk_dt in place is safe because only the
  # data.table that is returned by the filter function is used by
  # read_chunkwise_dt()
  chunk_dt[, `:=`(b = n, a = a)]
  chunk_dt <- chunk_dt[b %% 5 == 0, .(a, b)]

  # crucially: return (a copy of) the processed data.table
  chunk_dt
}

read_chunkwise_dt(outfile, chunk_size = 150, filter = chunk_filter)

# read chunkwise, filtering via in-place transformation

chunk_transform <- function(chunk_dt) {
  chunk_dt[, c := paste(a, a, sep = ",")]
  chunk_dt[, a := NULL]
}

read_chunkwise_dt(
  outfile, chunk_size = 150, filter = chunk_transform, copy = FALSE
)
