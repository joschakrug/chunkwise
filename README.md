# Tools to Read Large Text Files in Chunks

## How to use this package

The main methods this package provides are `read_chunkwise` and `read_chunkwise_dt`. `read_chunkwise` is designed to read data from large text files (in particular CSV and related tabular formats) in chunks of an arbitrary number of lines. Most importantly, it allows users to specify a handler function to process each chunk before the next one is loaded. This is particularly useful when working with large data sources that are too large to load into memory, but of which only a fraction of variables or observations is actually relevant.

`read_chunkwise_dt` is a convenience wrapper around `read_chunkwise` that automatically loads chunks as `data.table`s and binds them together row-wise.

### Why not just use `data.table`'s `fread`?

In principle, it is possible to implement chunk-wise loading of large tabular data files by combining the `skip` and `nrow` parameters of the `data.table::fread` function. However, this becomes very slow for large data files because `fread` starts from the beginning of the data file in each iteration and runs through the first `skip` lines before every chunk. `read_chunkwise`, on the other hand, uses an efficient C++ implementation under the hood to only walk through the entire data file once and send the current chunk to an R handler.

## Building and testing workflows (for developers only)

After making any changes to any code in the `src` or `R` directories, run

```{R}
devtools::clean_dll()
devtools::document()
devtools::load_all()
```

from the package root. This will ensure automatically that the package description etc. are consistent, even across R and C++ parts of the package, and create a clean local debug build.

To ensure the package still passes all tests after you have made any changes, run

```{R}
devtools::test()
```

from the package root.
