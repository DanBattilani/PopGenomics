#!/bin/bash
# MAIN PRINCIPLE: the larger the dataset to phase, the higher the phasing quality.

# Input settings
plink_prefix="file"
map_file="genetic_map.txt"
ids_file="file.subset.inds"
out_prefix="file.phased"

# Haplotype phasing starting from bed/bim/fam (binary PLINK files) using SHAPEIT2.
shapeit --input-bed "${plink_prefix}.bed" "${plink_prefix}.bim" "${plink_prefix}.fam" \
    --input-map "$map_file" \
    --output-haps "${out_prefix}.haps" "${out_prefix}.sample"


#-------------------------------------------------------------------------------------------
# (if needed) exclude/include individuals to only phase a particular set of samples (.inds -> one column with individual IDs)
# EXCLUDE
shapeit --input-bed "${plink_prefix}.bed" "${plink_prefix}.bim" "${plink_prefix}.fam" \
    --input-map "$map_file" \
    --exclude-ind "$ids_file" \
    --output-haps "${out_prefix}.exclude"

# INCLUDE
shapeit --input-bed "${plink_prefix}.bed" "${plink_prefix}.bim" "${plink_prefix}.fam" \
    --input-map "$map_file" \
    --include-ind "$ids_file" \
    --output-haps "${out_prefix}.include"


#-------------------------------------------------------------------------------------------
# SHAPEIT generates .haps file which you may want to convert to other formats.
shapeit --convert \
    --input-haps "$out_prefix" \
    --output-ref "${out_prefix}.hap" "${out_prefix}.leg" "${out_prefix}.sam"

# You can also convert to VCF
shapeit --convert \
    --input-haps "$out_prefix" \
    --output-vcf "${out_prefix}.vcf"


#-------------------------------------------------------------------------------------------
# You can subset the phased dataset.
# EXCLUDE
shapeit --convert \
    --input-haps "$out_prefix" \
    --exclude-ind "$ids_file" \
    --output-haps "${out_prefix}.subset"

# INCLUDE
shapeit --convert \
    --input-haps "$out_prefix" \
    --include-ind "$ids_file" \
    --output-haps "${out_prefix}.subset"

