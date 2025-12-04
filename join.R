#!/usr/bin/env Rscript

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is not installed.")
}

library(dplyr)

cat("dplyr version:", as.character(packageVersion("dplyr")), "\n")

input_metadata <- "input/sample_metadata.csv"
input_ms       <- "input/mass_spec_results.csv"

sample_metadata   <- read.csv(input_metadata, stringsAsFactors = FALSE)
mass_spec_results <- read.csv(input_ms,       stringsAsFactors = FALSE)

# Anti left
anti_left <- anti_join(
  sample_metadata,
  mass_spec_results,
  by = "sample_id"
)

# Anti right
anti_right <- anti_join(
  mass_spec_results,
  sample_metadata,
  by = "sample_id"
)

# Anti outer
anti_outer <- bind_rows(
  anti_left  %>% mutate(source_table = "sample_metadata"),
  anti_right %>% mutate(source_table = "mass_spec_results")
)

dir.create("output", showWarnings = FALSE)

write.csv(anti_left,  "output/anti_left.csv",  row.names = FALSE)
write.csv(anti_right, "output/anti_right.csv", row.names = FALSE)
write.csv(anti_outer, "output/anti_outer.csv", row.names = FALSE)