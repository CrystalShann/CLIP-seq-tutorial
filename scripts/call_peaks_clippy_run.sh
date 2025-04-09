#!/bin/bash
#SBATCH --job-name=clippy_job                # Job name
#SBATCH --output=clippy_job_%j.log           # Output log file
#SBATCH --error=clippy_job_%j.err            # Error log file
#SBATCH --ntasks=10                          # Number of tasks (CPU cores)
#SBATCH --mem-per-cpu=4G                     # Memory allocation per CPU (4 GB per CPU)
#SBATCH --time=12:00:00                      # Maximum runtime (12 hours)

# Activate the environment
source ~/envs/clippy/bin/activate

# Paths to required files
BED_DIR="/home/crystal/scratch/Me31B_Fmr1_KD_library1/nextflow_processed_2/xlinks"
ANNOTATION_GTF_GZ="/home/crystal/scratch/genome/Drosophila_melanogaster.BDGP6.32.109.gtf.gz"
FAI_INDEX="/home/crystal/scratch/genome/dmel-all-chromosome-r6.61.fasta.fai"
OUTPUT_DIR="/home/crystal/scratch/Me31B_Fmr1_KD_library1/nextflow_processed_2/clippy"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Step 1: Unzip the annotation file
gunzip -c "$ANNOTATION_GTF_GZ" > "$OUTPUT_DIR/fly_genome_annotation_BDGP6.gtf"

# Step 2: Process each BED file
for BED_FILE in "$BED_DIR"/*.xl.bed.gz; do
    # Extract sample name from filename
    BASENAME=$(basename "$BED_FILE" .xl.bed.gz)

    # Unzip BED file
    gunzip -c "$BED_FILE" > "$OUTPUT_DIR/${BASENAME}.bed"

    # Run clippy command
    clippy -i "$OUTPUT_DIR/${BASENAME}.bed" \
           -o "$OUTPUT_DIR/${BASENAME}_clippy_out" \
           -a "$OUTPUT_DIR/fly_genome_annotation_BDGP6.gtf" \
           -g "$FAI_INDEX"
done

echo "Clippy processing completed for all BED files."
