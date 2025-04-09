## this is for running icount-mini locally with conda environment                  
# activate conda environment
conda activate icount-mini

# run icount-segment command
iCount-Mini segment --report_progress \
                   /home/crystal/scratch/genome/Drosophila_melanogaster.BDGP6.32.109.gtf.gz \
                   /home/crystal/scratch/icount_outputs/dmel_segments.gtf \
                   /home/crystal/scratch/genome/dmel-all-chromosome-r6.61.fasta.fai

