#!/bin/bash

#--------------------------------------------------
# Nucleotide Diversity Estimation using VCFtools
#--------------------------------------------------

# Description:
# This script calculates nucleotide diversity (π) across the genome
# using non-overlapping windows of 1Mb (1,000,000 bp).
# NOTE: Do not apply MAF filtering beforehand if the goal is to capture
# rare alleles, as this may bias the diversity estimate.

# Requirements:
# - VCFtools installed and available in $PATH
# - Input VCF file should be compressed (.vcf.gz) and indexed (.tbi), or uncompressed (.vcf)

# Input/Output Paths
INPUT_VCF="path/to/input.vcf"        # Full path to input VCF file
OUTPUT_PREFIX="path/to/output/pi"    # Prefix for output file(s)

# Parameters
WINDOW_SIZE=1000000                  # Size of window in base pairs (e.g., 1,000,000 = 1Mb)

# Run nucleotide diversity calculation
vcftools \
  --vcf "$INPUT_VCF" \
  --window-pi $WINDOW_SIZE \
  --out "$OUTPUT_PREFIX"

# Output:
# ${OUTPUT_PREFIX}.windowed.pi : Contains window-based estimates of nucleotide diversity