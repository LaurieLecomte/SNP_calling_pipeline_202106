#!/bin/bash

# Merge VCFs for all chromosomes together
# Run this script from SNP_calling_pipeline_202106 directory using :
# srun -c 1 --mem=10G -p medium --time=7-00:00:00 -J 02_merge -o log/02_merge_%j.log 01_scripts/02_merge_20210626.sh &

# VARIABLES
CHR_LIST="02_infos/chr_list.txt"
OUT_DIR="03_results"
MERGED_DIR="04_merged"

# 1. Create output file header based on one vcf file
FIRST_CHR=$(less $CHR_LIST | head -n1)
zgrep '^#' $OUT_DIR/"$FIRST_CHR".vcf.gz | grep -v '^##contig=<ID=scaf' > $MERGED_DIR/merged_20210626.vcf

# 2. Concat all VCFs together without their header lines beginning with '#' 
cat $CHR_LIST | while read CHR
do
  zgrep -v '^#' $OUT_DIR/"$CHR".vcf.gz >> $MERGED_DIR/merged_20210626.vcf
done

# 3. Compress 
bgzip $MERGED_DIR/merged_20210626.vcf