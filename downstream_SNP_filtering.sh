#!/bin/bash
#SBATCH --job-name=filt
#SBATCH --output=filt.out
#SBATCH --error=filt.err
#SBATCH --partition=cpuqueue
#SBATCH --qos=normal 
#SBATCH --ntasks=1
#SBATCH --array=1
#SBATCH --mem-per-cpu=40G    # total memory
#SBATCH --cpus-per-task=6  # number of cpus / threads
#SBATCH --time=01:00:00    # time

# Edit these variables for your run
input_vcf="/path/to/input/file.hf.vcf.gz"
output_prefix="file"

# Modules required for filtering
modules=(perl/5.26.3 gsl/2.5 vcftools bcftools/1.16)
for m in "${modules[@]}"; do
    module load "$m"
done

# Keep only SNPs
vcftools --gzvcf "$input_vcf" \
    --remove-indels --recode --stdout \
    > "${output_prefix}.SNP.vcf"

# And let's do a version keeping only autosomes too (excluding X & Y).
vcftools --vcf "${output_prefix}.SNP.vcf" --not-chr chrX --not-chr chrY --recode --stdout > "${output_prefix}.SNP.noXY.vcf"

# DOWNSTREAM FILTERING
# MAF, missingness, minimum quality, minmum & maximum number of alleles, minimum & maximum depth (including their mean too).
# A rule of thumb is to filter minimum/maximum and average minimum/maximum depth based on half/double the coverage of your samples with minimum/maximum coverage respectively.
vcftools --vcf "${output_prefix}.SNP.noXY.vcf" \
--maf 0.05 --max-missing 0.9 --minQ 30 \
--min-alleles 2 --max-alleles 2 \
--minDP 5 --min-meanDP 5 \
--maxDP 55 --max-meanDP 55 --recode --stdout \
> "${output_prefix}.SNP.noXY.filt.vcf"
