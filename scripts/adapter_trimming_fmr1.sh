#!/bin/bash

#SBATCH --job-name=trim_fmr1        # Job name
#SBATCH --output=adapter_trim_fmr1_%j.log   # Output log file
#SBATCH --error=adapter_trim_fmr1_%j.err    # Error log file
#SBATCH --ntasks=6                         # Only 1 CPU needed
#SBATCH --mem-per-cpu=6G                           # Memory allocation
#SBATCH --time=10:00:00                    # Runtime (adjust as needed)

# Activate python environment
source ~/envs/cutadapt/bin/activate

# Set input and output directories
input_dir="/home/crystal/scratch/clip-seq/replicate3/Fmr1"
output_dir="/home/crystal/scratch/clip-seq/replicate3/Fmr1"
adapters_removed_dir="${output_dir}/adapters_removed"
logs_dir="${adapters_removed_dir}/logs"

# Make output directories if they don't exist
mkdir -p "$adapters_removed_dir" "$logs_dir"

# Set CPU count if not already set
cpus=${cpus:-4}

# Loop through all read pairs
for r1_file in "$input_dir"/*_1.fq.gz; do
    r2_file="${r1_file/_1.fq.gz/_2.fq.gz}"

    # Check if paired file exists
    if [[ ! -f "$r2_file" ]]; then
        echo "Warning: Paired file for $r1_file not found. Skipping..."
        continue
    fi

    # Extract sample name (strip full path and _1.fq.gz)
    sample_name=$(basename "$r1_file" _1.fq.gz)
    echo "Processing sample: $sample_name"

    # Run Cutadapt
    cutadapt \
        -j "$cpus" \
        --match-read-wildcards \
        --times 1 \
        -e 0.1 \
        -O 1 \
        --quality-cutoff 6 \
        -m 18 \
        -a NNNNNAGATCGGAAGAGCACACGTCTGAACTCCAGTCAC \
        -g CTTCCGATCTACAAGTT \
        -g CTTCCGATCTTGGTCCT \
        -A AACTTGTAGATCGGA \
        -A AGGACCAAGATCGGA \
        -A ACTTGTAGATCGGAA \
        -A GGACCAAGATCGGAA \
        -A CTTGTAGATCGGAAG \
        -A GACCAAGATCGGAAG \
        -A TTGTAGATCGGAAGA \
        -A ACCAAGATCGGAAGA \
        -A TGTAGATCGGAAGAG \
        -A CCAAGATCGGAAGAG \
        -A GTAGATCGGAAGAGC \
        -A CAAGATCGGAAGAGC \
        -A TAGATCGGAAGAGCG \
        -A AAGATCGGAAGAGCG \
        -A AGATCGGAAGAGCGT \
        -A GATCGGAAGAGCGTC \
        -A ATCGGAAGAGCGTCG \
        -A TCGGAAGAGCGTCGT \
        -A CGGAAGAGCGTCGTG \
        -A GGAAGAGCGTCGTGT \
        -o "${adapters_removed_dir}/${sample_name}.1.adapterTrim.fastq.gz" \
        -p "${adapters_removed_dir}/${sample_name}.2.adapterTrim.fastq.gz" \
        "$r1_file" "$r2_file" \
        > "${logs_dir}/${sample_name}.cutadapt.log"
done

