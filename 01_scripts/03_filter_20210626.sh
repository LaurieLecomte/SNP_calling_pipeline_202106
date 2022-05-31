#!/bin/bash

# Filter SNPs 
# Run this script from SNP_calling_pipeline_202106 directory using :
# srun -c 1 --mem=10G -p medium --time=7-00:00:00 -J 03_filter -o log/03_filter_%j.log 01_scripts/03_filter_20210626.sh &

# VARIABLES
OUT_DIR="03_results"
MERGED_DIR="04_merged"
FILT_DIR="05_filtered"

# LOAD REQUIRED MODULES
module load bcftools/1.12
module load vcftools
module load htslib/1.8


# 1. Filter with bcftools
bcftools filter -e 'MQ < 30' $MERGED_DIR/merged_20210626.vcf.gz -Ov > $FILT_DIR/filtered_20210626.tmp.vcf
## print number of filtered sites
zgrep -v ^\#\# $FILT_DIR/filtered_20210626.tmp.vcf | wc -l

# 2. Filter with vcftools
echo "
>>> Filtering through VCFtools now!!
"
vcftools --gzvcf $FILT_DIR/filtered_20210626.tmp.vcf \
    --minQ 30 \
    --minGQ 20 \
    --minDP 5 \
    --mac 2 \
    --max-alleles 2 \
    --max-missing 0.7 \
    --maf 0.05 \
    --recode \
    --stdout > $FILT_DIR/filtered_20210626.vcf

# 3. Compress and tabix
bgzip $FILT_DIR/filtered_20210626.vcf
tabix -p vcf $FILT_DIR/filtered_20210626.vcf.gz
