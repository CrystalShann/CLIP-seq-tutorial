#!/bin/bash
#SBATCH --job-name=nextflow_clipseq               # Job name
#SBATCH --output=nextflow_clipseq_%j.log          # Output log file
#SBATCH --error=nextflow_clipseq_%j.err           # Error log file
#SBATCH --ntasks=1                                # One task for the entire Nextflow run
#SBATCH --cpus-per-task=12                         # Allocating # CPUs to the task
#SBATCH --mem-per-cpu=16G                         # Memory allocation per CPU 
#SBATCH --time=24:00:00                           # Maximum runtime (24 hours)

# Load necessary modules
module load StdEnv/2020
module load nextflow/22.10.6
module load apptainer/1.2.4 

# Set environment variables for Singularity and Nextflow
export NXF_SINGULARITY_CACHEDIR=/scratch/$USER/tmp
export NXF_WORK=/scratch/$USER/tmp

# Run the Nextflow pipeline
nextflow run nf-core/clipseq \
	--input '/home/crystal/scratch/samplesheet.csv' \
	--fasta '/home/crystal/scratch/genome/dmel-all-chromosome-r6.61.fasta' \
	--gtf '/home/crystal/scratch/genome/dmel-all-r6.61.gtf' \
	--outdir '/home/crystal/scratch/Me31B_Fmr1_KD_library1/nextflow_processed' \
	--star_index '/home/crystal/scratch/genome/STAR_index/STAR_dmel-all-chromosome-r6.61' \
	--peakcaller piranha \
	--smrna_org fruitfly \
	--motif true \
	-profile singularity
