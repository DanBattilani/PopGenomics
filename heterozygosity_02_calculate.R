#!/usr/bin/env Rscript
#
# heterozygosity_02_calculate.R
#
# This script scans all “est.<SAMPLE>.ml” files in a given directory,
# computes per-sample heterozygosity = (# heterozygous sites) / (total sites),
# and writes a tab‐delimited summary table.
#
# Usage:
#   Rscript calculate_heterozygosity.R /path/to/sfs_out/ output.tsv
#
#-------------------------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
  stop("Usage: Rscript calculate_heterozygosity.R <SFS_DIR> <OUTPUT_TABLE.tsv>\n",
       "Example: Rscript calculate_heterozygosity.R ./sfs_out/ heterozygosity_summary.tsv")
}

sfs_dir    <- args[1]
output_tsv <- args[2]

# List all files matching "est.*.ml"
ml_files <- list.files(path = sfs_dir, pattern = "^est\\..*\\.ml$", full.names = TRUE)
if (length(ml_files) == 0) {
  stop("No files matching 'est.<SAMPLE>.ml' found in directory: ", sfs_dir)
}

# Prepare a data frame to hold results
results <- data.frame(
  Sample       = character(),
  Heterozygosity = numeric(),
  stringsAsFactors = FALSE
)

# For each .ml file, read the two frequencies (folded‐SFS)
#   est.<SAMPLE>.ml ≡ a file with two numbers: [0] = count of monomorphic sites,
#                                             [1] = count of polymorphic (heterozygous) sites
#
for (ml_path in ml_files) {
  # Derive sample name from file name: remove "est." prefix and ".ml" suffix
  fname     <- basename(ml_path)
  sample_id <- sub("^est\\.(.*)\\.ml$", "\\1", fname)

  # Read the two values
  sfs_vals <- scan(ml_path, quiet = TRUE)
  if (length(sfs_vals) < 2) {
    warning("File ", ml_path, " does not contain at least two values. Skipping.")
    next
  }
  het_count   <- sfs_vals[2]
  total_sites <- sum(sfs_vals)

  if (total_sites == 0) {
    het_prop <- NA_real_
  } else {
    het_prop <- het_count / total_sites
  }

  results <- rbind(
    results,
    data.frame(
      Sample         = sample_id,
      Heterozygosity = het_prop,
      stringsAsFactors = FALSE
    )
  )
}

# Write summary to TSV
write.table(results,
            file      = output_tsv,
            sep       = "\t",
            quote     = FALSE,
            row.names = FALSE)

cat("→ Wrote heterozygosity summary for", nrow(results), "samples to:\n  ", output_tsv, "\n")
