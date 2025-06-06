# MAIN PRINCIPLE: the larger the dataset to phase, the higher the phasing quality.

# Haplotype phasing starting from bed/bim/fam (binary PLINK files) using SHAPEIT2.
shapeit --input-bed file.bed file.bim file.fam \
--input-map genetic_map.txt \
--output-haps file.phased.haps file.phased.sample


#-------------------------------------------------------------------------------------------
# (if needed) exclude/include individuals to only phase a particular set of samples (.inds -> one column with individual IDs)
# EXCLUDE
shapeit --input-bed file \
--input-map genetic_map.txt \
--exclude-ind file.subset.inds \
--output-haps file.phased

# INCLUDE
shapeit --input-bed file \
--input-map genetic_map.txt \
--include-ind file.subset.inds \
--output-haps file.phased


#-------------------------------------------------------------------------------------------
# SHAPEIT generates .haps file which you may want to convert to other formats.
shapeit --convert \
--input-haps file.phased \
--output-ref file.phased.hap file.phased.leg file.phased.sam

# You can also convert to VCF
shapeit --convert \
--input-haps file.phased \
--output-vcf file.phased.vcf


#-------------------------------------------------------------------------------------------
# You can subset the phased dataset.
# EXCLUDE
shapeit --convert \
--input-haps file.phased \
--exclude-ind file.subset.inds \
--output-haps subset.phased

# INCLUDE
shapeit --convert \
--input-haps file.phased \
--include-ind file.subset.inds \
--output-haps subset.phased

