#!/bin/bash
#SBATCH --job-name=umi_extract_job        # Job name
#SBATCH --output=umi_extract_job_%j.log   # Output log file
#SBATCH --error=umi_extract_job_%j.err    # Error log file
#SBATCH --ntasks=16                        # Number of tasks (CPU cores)
#SBATCH --mem-per-cpu=4G                 # Memory allocation per CPU (16 GB)
#SBATCH --time=12:00:00                   # Maximum runtime (12 hours)

# Activate the virtual environment
source /home/crystal/tools/bin/activate

# Create the output directory if it doesn't exist
output_dir="/home/crystal/scratch/clip-seq/me31b/UMI_moved"
mkdir -p "$output_dir"

# Input directory containing the files
input_dir="/home/crystal/scratch/clip-seq/me31b/adapters_removed"

# Find files matching the pattern and process with UMI-tools
for file in "${input_dir}"/me31b.read.1.adapterTrim.round2.fastq.gz; do
    # Extract base name (remove path and extension)
    base_name=$(basename "$file" .fastq.gz)
    
    # Run UMI-tools extract
    umi_tools extract \
        --random-seed 1 \
        --bc-pattern='NNNNNNNNNNNNNNN' \
        --log "${output_dir}/${base_name}_umi_extraction.log" \
        --stdin "$file" \
        --stdout "${output_dir}/${base_name}.umi_extracted.fastq.gz"
done

# Deactivate the virtual environment
deactivate
