#!/bin/bash
#SBATCH --job-name=umi_extract_fmr1        # Job name
#SBATCH --output=umi_extract_fmr1_%j.log   # Output log file
#SBATCH --error=umi_extract_fmr1_%j.err    # Error log file
#SBATCH --ntasks=4                         # Only 1 CPU needed
#SBATCH --mem-per-cpu=4G                           # Memory allocation
#SBATCH --time=12:00:00                    # Runtime (adjust as needed)

# Activate the virtual environment
source ~/envs/tools/bin/activate

# Define directories
input_dir="/home/crystal/scratch/clip-seq/replicate3/Fmr1/adapters_removed"
output_dir="/home/crystal/scratch/clip-seq/replicate3/Fmr1/UMI_moved"
mkdir -p "$output_dir"

# Define input file (read 1 only)
input_file="${input_dir}/Fmr1_CKDL250012622-1A_22T5WLLT4_L1.1.adapterTrim.fastq.gz"
base_name=$(basename "$input_file" .fastq.gz)

# Run UMI-tools extract
umi_tools extract \
    --random-seed 1 \
    --bc-pattern='NNNNNNNNNNNNNNN' \
    --log "${output_dir}/${base_name}_umi_extraction.log" \
    --stdin "$input_file" \
    --stdout "${output_dir}/${base_name}.umi_extracted.fastq.gz"

