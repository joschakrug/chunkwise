#include <Rcpp.h>
#include <fstream>
#include <vector>

using namespace Rcpp;

std::string concat_chunk(
        std::vector<std::string> chunk,
        std::string header = "",
        bool trailing_newline = true
    ) {
    // combine all lines to one single string
    std::stringstream chunk_text;

    if (header != "") {
        chunk_text << header;
    }

    for (const auto& l : chunk) {
        chunk_text << l << "\n";
    }

    std::string chunk_text_str = chunk_text.str();
    if (!trailing_newline) chunk_text_str.pop_back();

    return chunk_text_str;
}

//' Read in a text file, chunk by chunk
//'
//' Read text file `filepath` in chunks of `chunk_size` lines and pass each
//' chunk to a user-provided `handler` function.
//'
//' @param filepath Path to the file to read
//' @param handler User-provided handler function to which chunks will be passed
//' @param chunk_size number of lines to read in as one chunk (defaults to 100000)
//' @param repeat_header Append header line(s) to beginning of each chunk
//'     (defaults to TRUE)
//' @param header_rows number of lines at the beginning of file to consider as header
//' @param skip number of lines at the beginning of the file to skip (defaults to 0)
//' @param max_rows If not `NULL`, only read the first `max_rows` lines of data
//'
//' @useDynLib chunkwise, .registration = TRUE
//' @importFrom Rcpp loadModule
//'
//' @export
// [[Rcpp::export]]
void read_chunkwise(
        const std::string& filepath,
        Function handler,
        size_t chunk_size = 100000,
        bool repeat_header = true,
        size_t header_rows = 1,
        size_t skip = 0,
        Nullable<int> max_rows = R_NilValue
    ) {
    
    // open the text file
    std::ifstream file(filepath);
    if (!file.is_open()) {
        stop("Failed to open file: " + filepath);
    }

    // this is a string buffer to load the current line into
    std::string line;

    // skip lines if specified
    for (size_t i = 0; i < skip; ++i) {
        std::getline(file, line);
    }

    // read the file header
    std::stringstream header;
    for (size_t i = 0; i < header_rows; ++i) {
        std::getline(file, line);
        header << line << "\n";
    }

    // read in chunks as a vector of lines each
    std::vector<std::string> chunk;
    size_t counter = 0;
    size_t last_counter = 0;

    // run through the file line by line...
    while (std::getline(file, line) && (max_rows.isNull() || (counter < as<size_t>(max_rows)))) {
        // append the current line to the end of the chunk vector and increment
        // the counter
        chunk.push_back(line);
        counter++;

        // ...and pass the current batch of lines to the R handler whenever we
        // finish a chunk
        if (counter % chunk_size == 0) {

            std::cout << "Processing lines " << last_counter + 1 << " to ";
            std::cout << counter << "\n";

            // call the R handler provided to this function
            try {
                if (repeat_header || (counter <= chunk_size)) {
                    handler(concat_chunk(chunk, header.str()));
                }
                else {
                    handler(concat_chunk(chunk));
                }
            }
            catch (...) {
                // if an error occurred in the R handler
                chunk.clear();
                file.close();
                stop("Error in R handler function");
            }
            chunk.clear();
            last_counter = counter;
        }
    }

    // process the last partial chunk
    if (!chunk.empty()) {
        std::string chunk_text;
        if (repeat_header || (counter <= chunk_size)) {
            chunk_text = concat_chunk(chunk, header.str());
        }
        else {
            chunk_text = concat_chunk(chunk);
        }

        std::cout << chunk_text;

        handler(chunk_text);
    }

    // close the text file
    file.close();
}
