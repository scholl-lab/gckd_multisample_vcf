# Commands to merge and annotate GCKD single sample VCFs

## A) Merge single sample VCFs
Using code from [scholl-lab/merge-multisample-vcf](https://github.com/scholl-lab/merge-multisample-vcf), merge the VCFs for each sample into a single VCF. This will be used for annotation.

### 1) Download the snakemake and shell scripts
```
wget https://raw.githubusercontent.com/scholl-lab/merge-multisample-vcf/main/merge_sequential.smk
wget https://raw.githubusercontent.com/scholl-lab/merge-multisample-vcf/main/run_merge_sequential.sh
```

### 2) Edit the run_merge_sequential.sh script
Before running the pipeline to set up the config.yaml file as described in the [scholl-lab/merge-multisample-vcf](https://github.com/scholl-lab/merge-multisample-vcf) README.md file.

### 3) Run the pipeline
This will merge the VCFs for each sample into a single VCF. The resulting VCF `all_merged.vcf.gz` will be in the `results/final` directory.
```
sbatch run_merge_sequential.sh
```

## B) Scatter the merged VCF into smaller chunks for annotation
Using the bcftools scatter plugin the merged VCF is split (100k variants per file) into smaller chunks for annotation. This will be used for annotation.

### 1) Create a directory to store the scattered VCFs
```
mkdir -p results/scatter/
```

### 2) Run the bcftools scatter plugin
This will split the VCF into smaller chunks to allow for parallel annotation.
Bcftools was used in Version: 1.17 (using htslib 1.17) using the following command.
it was installed using mamba with `mamba create -n bcftools bcftools`.
Activate the conda environment containing bcftools.

Parameters are set as follows:
- `+scatter` - run the scatter plugin
- `results/final/all_merged.vcf.gz` - the input VCF
- `-Oz` - output a compressed VCF
- `--threads 4` - use 4 threads
- `-o results/scatter/` - output directory
- `-n 100000` - number of variants per file
- `-p all_merged.` - prefix for the output files

```
conda activate bcftools
bcftools +scatter results/final/all_merged.vcf.gz -Oz --threads 4 -o results/scatter/ -n 100000 -p all_merged.
```

As the jo takes relatively long to run, it is recommended to submit it as a cluster job using the following command (helper script in `scripts/bcftools_scatter.sh`)):
```bash
sbatch bcftools_scatter.sh
```

You can also provide command line arguments to override the default parameter values of the script, for example:
```bash
sbatch bcftools_scatter.sh my_input.vcf.gz my_output_directory/ 50000 my_prefix.
```

Defaults are set as follows:
- `INFILE=${1:-results/final/all_merged.vcf.gz}`
- `OUTDIR=${2:-results/scatter/}`
- `VARIANTS=${3:-100000}`
- `PREFIX=${4:-all_merged.}`
