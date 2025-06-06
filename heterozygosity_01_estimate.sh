#!/usr/bin/env bash
set -euo pipefail

#-------------------------------------------------------------------------------
# heterozygosity_01_estimate.sh
#
# This script:
#   1. Selects only autosomal chromosomes from each BAM.
#   2. Runs ANGSD to compute genotype likelihoods (dosaf/gl model).
#   3. Runs realSFS to estimate the genome‐wide SFS (.ml) for each sample.
#
# Usage:
#   1. Edit the variables below (REF_GENOME, CHROMS, SAMPLE_LIST, IN_DIR, OUT_DIR).
#   2. Make the script executable: chmod +x estimate_heterozygosity.sh
#   3. Run: ./estimate_heterozygosity.sh
#-------------------------------------------------------------------------------

####### USER‐EDITED VARIABLES ###############################################

# Full path to the reference genome (fasta).  (Used for both -ref and -anc in ANGSD.)
REF_GENOME="/path/to/canFam31.fasta"

# List of autosomal chromosomes to keep (space‐separated).
# e.g. "chr1 chr2 ... chr38" for the dog genome.
CHROMS="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chr23 chr24 chr25 chr26 chr27 chr28 chr29 chr30 chr31 chr32 chr33 chr34 chr35 chr36 chr37 chr38"

# Directory containing the original filtered BAMs (ending in .filtered.bam).
# e.g. /projects/myproj/alignments/
IN_DIR="/path/to/input_bams"

# Directory to write all intermediate and final files.
# The script will create subdirectories: autosomes/, angsd_out/, sfs_out/
OUT_DIR="/path/to/output_directory"

# Name of a file (or literal list) with one sample ID per line.  Each line
# should correspond to a BAM file named <SAMPLE_ID>.filtered.bam in $IN_DIR.
# For example, if samples.txt contains:
#   SAMP1
#   SAMP2
#   SAMP3
#
# Then the script expects:
#   $IN_DIR/SAMP1.filtered.bam
#   $IN_DIR/SAMP2.filtered.bam
#   $IN_DIR/SAMP3.filtered.bam
#
# You can also replace SAMPLE_LIST with a literal array below, e.g.
#   SAMPLE_LIST=(WIT1 WIT2 WIT3 …)
#-------------------------------------------------------------------------------
SAMPLE_LIST_FILE="samples.txt"
#-------------------------------------------------------------------------------

# Load modules (adjust as needed on your cluster)
module load samtools
module load angsd

# Create output subdirectories
mkdir -p "${OUT_DIR}/autosomes"
mkdir -p "${OUT_DIR}/angsd_out"
mkdir -p "${OUT_DIR}/sfs_out"

# Read sample IDs into an array
mapfile -t SAMPLES < "${SAMPLE_LIST_FILE}"

#-------------------------------------------------------------------------------
# 1) Extract autosomes from each BAM using samtools view -b <chr list>
#-------------------------------------------------------------------------------
echo ">> Extracting autosomal reads from each BAM..."
for SAMPLE in "${SAMPLES[@]}"; do
    IN_BAM="${IN_DIR}/${SAMPLE}.filtered.bam"
    OUT_BAM="${OUT_DIR}/autosomes/${SAMPLE}.autosomes.bam"

    if [[ ! -f "${IN_BAM}" ]]; then
        echo ">> ERROR: Input BAM not found: ${IN_BAM}"
        exit 1
    fi

    echo "   - Processing ${SAMPLE}..."
    samtools view -b "${IN_BAM}" ${CHROMS} > "${OUT_BAM}"
done


#-------------------------------------------------------------------------------
# 2) Run ANGSD on each autosomal‐only BAM to produce .saf.idx
#    (uses -GL 1 for GATK model, -dosaf 1)
#    Adjust -minQ and -minMapQ thresholds and number of threads as needed
#-------------------------------------------------------------------------------
echo ">> Running ANGSD for each sample..."
NUM_THREADS=4       # number of threads to use in ANGSD
MIN_BASEQ=20        # minimum base quality
MIN_MAPQ=30         # minimum mapping quality

for SAMPLE in "${SAMPLES[@]}"; do
    BAM="${OUT_DIR}/autosomes/${SAMPLE}.autosomes.bam"
    ANGSD_PREFIX="${OUT_DIR}/angsd_out/${SAMPLE}"

    echo "   - ANGSD on ${SAMPLE}..."
    angsd \
        -i "${BAM}" \
        -ref "${REF_GENOME}" \
        -anc "${REF_GENOME}" \
        -dosaf 1 \
        -GL 1 \
        -minQ "${MIN_BASEQ}" \
        -minMapQ "${MIN_MAPQ}" \
        -P "${NUM_THREADS}" \
        -out "${ANGSD_PREFIX}"
done


#-------------------------------------------------------------------------------
# 3) Run realSFS on each .saf.idx to get an estimated SFS (.ml)
#-------------------------------------------------------------------------------
echo ">> Running realSFS to estimate SFS..."
for SAMPLE in "${SAMPLES[@]}"; do
    SAF_IDX="${OUT_DIR}/angsd_out/${SAMPLE}.saf.idx"
    OUTPUT_ML="${OUT_DIR}/sfs_out/est.${SAMPLE}.ml"

    if [[ ! -f "${SAF_IDX}" ]]; then
        echo ">> ERROR: SAF index not found for ${SAMPLE}: ${SAF_IDX}"
        exit 1
    fi

    echo "   - realSFS for ${SAMPLE}..."
    realSFS "${SAF_IDX}" -P "${NUM_THREADS}" > "${OUTPUT_ML}"
done

echo ">> All ANGSD and realSFS jobs completed. Results are in ${OUT_DIR}/sfs_out/"
