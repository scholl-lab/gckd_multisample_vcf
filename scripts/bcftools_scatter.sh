#!/bin/bash
#
#SBATCH --job-name=bcftools_scatter
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --time=168:00:00
#SBATCH --mem-per-cpu=8000M
#SBATCH --output=slurm_logs/%x-%j.log

# based on:
# https://hpc-docs.cubi.bihealth.org/best-practice/temp-files/#tmpdir-and-the-scheduler
# https://bihealth.github.io/bih-cluster/slurm/snakemake/#custom-logging-directory

# First, point TMPDIR to the scratch in your home as mktemp will use this
export TMPDIR=$HOME/scratch/tmp
# Second, create another unique temporary directory within this directory
export TMPDIR=$(mktemp -d)
# Finally, setup the cleanup trap
trap "rm -rf $TMPDIR" EXIT

mkdir -p slurm_logs
export SBATCH_DEFAULTS=" --output=slurm_logs/%x-%j.log"

# Get the input file from the command line argument, default to "results/final/all_merged.vcf.gz" if not provided
INFILE=${1:-results/final/all_merged.vcf.gz}

# Get the output directory from the command line argument, default to "results/scatter/" if not provided
OUTDIR=${2:-results/scatter/}

# Get the number of variants to scatter into each file from the command line argument, default to 100000 if not provided
VARIANTS=${3:-100000}

# Get the prefix for the output files from the command line argument, default to "all_merged." if not provided
PREFIX=${4:-all_merged.}

date
source activate bcftools
bcftools +scatter $INFILE -Oz --threads 4 -o $OUTDIR -n $VARIANTS -p $PREFIX
date