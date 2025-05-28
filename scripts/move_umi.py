import gzip
from Bio import SeqIO

# Input and output file paths (modify as needed)
input_file = "/home/crystal/scratch/clip-seq/me31b/UMI_moved/me31b.read.1.adapterTrim.round2.umi_extracted.fastq.gz"
output_file = "/home/crystal/scratch/clip-seq/me31b/UMI_moved/me31b.read.1.umi_moved.fastq.gz"

def modify_header(input_file, output_file):
    with gzip.open(input_file, "rt") as infile, gzip.open(output_file, "wt") as outfile:
        for record in SeqIO.parse(infile, "fastq"):
            # Split the header to extract the UMI and the original header
            parts = record.id.split('_')
            if len(parts) == 2:
                original_header = parts[0]
                umi = parts[1]  # Extract the UMI

                # Create new header with UMI moved to the end
                new_header = f"{original_header}_{umi}"
                record.id = new_header
                record.description = new_header  # Update description to match new header

            # Write the modified record to the output file
            SeqIO.write(record, outfile, "fastq")

# Run the function
modify_header(input_file, output_file)
print(f"Headers modified and output written to {output_file}.")
