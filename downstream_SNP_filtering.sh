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

module load perl/5.26.3
module load gsl/2.5
module load vcftools
module load bcftools/1.16

# Keep only SNPs
vcftools --gzvcf /path/to/input/file.hf.vcf.gz \
--remove-indels --recode --stdout \
> file.SNP.vcf

# And let's do a version keeping only autosomes too (excluding X & Y).
vcftools --vcf file.SNP.vcf --not-chr chrX --not-chr chrY --recode --stdout > file.SNP.noXY.vcf





#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#!/bin/bash
#SBATCH -J lastfilt      ## you can give whatever name you want here to identify your job
#SBATCH -o lastfilt.log  ## name a file to save log of your job
#SBATCH -e lastfilt.error   ## save error message if any
##SBATCH --mail-user=example@example.dk ## your email account to receive notification of job status
##SBATCH --mail-type=ALL        ## ALL mean you will receive everything about your job, such like start running, fail, or fi$
#SBATCH -t 01:00:00 ## give an estimation of how long is your job going to run, format HH:MM:SS (1-10 days in this case)
#SBATCH -c 6   ## number cpus
#SBATCH --mem=40gb     ## total RAM

module load perl/5.26.3
module load gsl/2.5
module load vcftools
module load bcftools/1.16

# DOWNSTREAM FILTERING
# MAF, missingness, minimum quality, minmum & maximum number of alleles, minimum & maximum depth (including their mean too).
# A rule of thumb is to filter minimum/maximum and average minimum/maximum depth based on half/double the coverage of your samples with minimum/maximum coverage respectively.
vcftools --vcf file.SNP.noXY.vcf \
--maf 0.05 --max-missing 0.9 --minQ 30 \
--min-alleles 2 --max-alleles 2 \
--minDP 5 --min-meanDP 5 \
--maxDP 55 --max-meanDP 55 --recode --stdout \
> file.SNP.noXY.filt.vcf