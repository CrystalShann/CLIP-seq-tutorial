#!/bin/bash
#SBATCH --job-name=peka_job                      # Job name
#SBATCH --output=peka_job_%j.log                 # Output log file
#SBATCH --error=peka_job_%j.err                  # Error log file
#SBATCH --ntasks=4                               # Number of tasks
#SBATCH --mem-per-cpu=8G                         # Memory allocation per CPU
#SBATCH --time=12:00:00                          # Maximum runtime (12 hours)

# Activate conda environment
source ~/envs/peka/bin/activate

# Define directories
PEAKS_DIR="/home/crystal/scratch/Me31B_Fmr1_KD_library1/nextflow_processed_2/clippy"
XLINKS_DIR="/home/crystal/scratch/Me31B_Fmr1_KD_library1/nextflow_processed_2/clippy"
OUTPUT_BASE_DIR="/home/crystal/scratch/Me31B_Fmr1_KD_library1/nextflow_processed_2/peka"

# Reference files
GENOME="/home/crystal/scratch/genome/dmel-all-chromosome-r6.61.fasta"
GENOME_INDEX="/home/crystal/scratch/genome/dmel-all-chromosome-r6.61.fasta.fai"
REGIONS="/home/crystal/scratch/icount_outputs/regions.gtf.gz"

# Loop over peak files
for PEAK_FILE in "$PEAKS_DIR"/*_clippy_out_rollmean10_minHeightAdjust1.0_minPromAdjust1.0_minGeneCount5_Peaks.bed; do
    # Extract sample name
    SAMPLE_NAME=$(basename "$PEAK_FILE" "_clippy_out_rollmean10_minHeightAdjust1.0_minPromAdjust1.0_minGeneCount5_Peaks.bed")

    # Define corresponding xlinks file
    XLINKS_FILE="$XLINKS_DIR/${SAMPLE_NAME}.bed"

    # Ensure the xlinks file exists before running PEKA
    if [ ! -f "$XLINKS_FILE" ]; then
        echo "Warning: Xlinks file not found for $SAMPLE_NAME, skipping..."
        continue
    fi

    # Create output directory for the sample
    SAMPLE_OUTPUT_DIR="${OUTPUT_BASE_DIR}/${SAMPLE_NAME}"
    mkdir -p "$SAMPLE_OUTPUT_DIR"

    # Run PEKA command
    echo "Processing $SAMPLE_NAME..."
    peka -i "$PEAK_FILE" \
         -x "$XLINKS_FILE" \
         -g "$GENOME" \
         -gi "$GENOME_INDEX" \
         -r "$REGIONS" \
         -a True \
         -o "$SAMPLE_OUTPUT_DIR"
done

echo "PEKA processing completed for all samples!"
