# CLIP-seq-tutorial

This tutorial is intended for processing of iiCLIP data following nf-core/CLIP-seq pipeline

## Download Drosophila reference genome and genome annotation files

1. Navigate to [Ensemble](https://ftp.ensembl.org/pub/release-113/fasta/drosophila_melanogaster/)

2. Download the reference genome

```bash
wget https://ftp.ensembl.org/pub/release-113/fasta/drosophila_melanogaster/dna/Drosophila_melanogaster.BDGP6.46.dna.toplevel.fa.gz
```

3. Download the GTF file; this is a text file that describes genes and transcripts annotation for a genome

``` bash
wget https://ftp.ensembl.org/pub/release-113/gtf/drosophila_melanogaster/Drosophila_melanogaster.BDGP6.46.113.gtf.gz
```

## List of softwares required for running CLIP-seq analysis

1. [nf-core/clipseq](https://nf-co.re/clipseq/1.0.0/)
This is a modular bioinformatics pipeline that identifies crosslink sites for iCLIP data. This will output crosslink sites in BED file format


3. [Clippy](https://github.com/ulelab/clippy)
Clippy enables peaks calling from the crosslink sites, it will output peaks in BED file format

3. [iCount-Mini](https://github.com/ulelab/iCount-Mini)
iCount-Mini segment was used to segment the  genome into regions of different types, such as intergenic, UTR3, UTR5, ncRNA, intron, CDS regions. This is required later for PEKA to identify k-mers relative to each genomic region.

4. [peka](https://github.com/ulelab/peka)
PEKA identifies motifs from crosslink sites and peaks

5. [ultraplex](https://github.com/ulelab/ultraplex)
Ultraplex is a specialized software designed for demultiplexing iCLIP data with customized barcode



## Install the softwares

Note: This is intented for running the analysis on Compute Canada Server

1. Log in to the server by typing the following command into the terminal

``` bash
<username>@cedar.computecanada.ca
```

2. Install the softwares by creating python virtual environments

Note: nf-core/nextflow is a pre-installed software on the server, so you don't need to install it yourself

To install Ultraplex (needs to run with Python 3.7)
```bash
module spider python
module load StdEnv/2020
module load python/3.7.9
cd ~/
mkdir envs
python3.7 -m venv ~/envs/ultraplex
# activate the environment every time you want to use it, the installation steps only needs to be done once
# i.e: run source ~/envs/ultraplex/bin/activate everytime you want to use ultraplex
source ~/envs/ultraplex/bin/activate 
pip install ultraplex 
```

To install Clippy
```bash
cd ~/scratch
git clone https://github.com/ulelab/clippy.git
cd clippy
module load StdEnv/2020
module load python/3.9.6
python3.9 -m venv ~/envs/clippy
source ~/envs/clippy/bin/activate
pip install .
pip install numpy pandas scipy matplotlib dash==1.20.0 dash-bootstrap-components==0.11.3 werkzeug==2.0.0 pybedtools numpydoc bs4 percy pytest pytest-cov pytest-selenium
```

To install iCount-Mini

Note: This software has many dependency issues with the Compute Canada server; it is recommended that you install the software locally using Miniconda

if you do NOT have miniconda installed on your local machine, install miniconda by running the following commands. Skip this step if you already have miniconda installed
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
chmod +x Miniconda3-latest-*.sh
./Miniconda3-latest-*.sh
source ~/.bashrc
```

Now you can proceed with installing iCount-Mini within an conda environment. (You can learn more about conda environments [here](https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html) )

```bash
conda create --name icount-mini python=3.9
# activate the environment everytime you want to use it
conda activate icount-mini
pip install --upgrade -r requirements-rtd.txt -e .
```

To install PEKA

```bash
cd ~/scratch
git clone https://github.com/ulelab/peka.git
cd peka
module spider python/3.10.2
module load python/3.10.2
python3.10 -m venv ~/envs/peka
source ~/envs/peka/bin/activate
pip install git+https://github.com/ulelab/peka@main
```

## CLIP-seq analysis
Now we are ready to proceed with the actual CLIP analysis!

To clone this repository onto your local machine, run the following command in your terminal:
```bash
cd ~/scratch
git clone https://github.com/CrystalShann/CLIP-seq-tutorial.git
```

If you are not demultiplexing the samples, you need to first move the random barcodes to the end of the read header for nextflow to run. First start by creating a python virtual environment on the server to install all the tools
```bash
module load python
python-m venv ~/envs/tools
source ~/envs/tools/bin/activate  # activate the environment every time you want to use it
pip install umi_tools             # you only need to install the software once
pip install biopython
```

Run umi_extract.sh first to extract the UMI to the header, and then run run_move_umi.sh to move the extracted UMI to the end of the header

For the umi_extract.sh script, you need to change the input and output directory to reflect your own file path
```bash
# for example, these lines needs to be changed to reflect your own file name
output_dir="/home/crystal/scratch/clip-seq/me31b/UMI_moved"
input_dir="/home/crystal/scratch/clip-seq/me31b/adapters_removed"
"${input_dir}"/me31b.read.1.adapterTrim.round2.fastq.gz
# for this specific line, ${input_dir} is a variable that points to the input_dir you specified earlier. You only need to 
# change the second part. (ie: if your file is named read1.fastq.gz, you can change this line to "${input_dir}"/read1.fastq.gz
```
Once you are done making the changes, you can submit the job by running
```bash
sbatch umi_extract.sh
```

After extracting the UMI, the UMI will be part of the read header. However, in order for the fastq format to be compatible with nextflow, we need to further process the fastq file so that the UMI is moved to the end of the read header the separated by "_"
To do this, you first need to modify the move_umi.py script to change the file path to your own directories
```bash
input_file = "/home/crystal/scratch/clip-seq/me31b/UMI_moved/me31b.read.1.adapterTrim.round2.umi_extracted.fastq.gz"
output_file = "/home/crystal/scratch/clip-seq/me31b/UMI_moved/me31b.read.1.umi_moved.fastq.gz"
```
Submit the job by running
```bash
sbatch run_move_umi.sh
```


** NOTE: REMEMBER TO CHANGE THE DIRECTORIES TO REFLECT WHERE YOUR FILES ARE LOCATED BEFORE SUBMITTING JOBS

1. To run ultraplex, we need to first prepare a csv file detailing the barcode. An example could be:
```bash
NNNNTCCACNNNNNN:Sample1_fmr1_no_xlink
NNNNCCGGANNNNNN:Sample2_fmr1_xlink
NNNNAGGCANNNNNN:Sample3_me31b_flag
NNNNGAATANNNNNN:Sample4_me31b_flag_fmr1_rnai
```
To create a new file in terminal
```
nano samplesheet.csv
```
  
2. To run nextflow, we need to first prepare a samplesheet (details can be found [here](https://nf-co.re/clipseq/1.0.0/docs/usage/))
An example samplesheet would be:
```bash
sample,fastq
Sample2_fmr1_xlink,/home/crystal/scratch/Me31B_Fmr1_KD_library1/demultiplex/ultraplex_demux_Sample2_fmr1_xlink.fastq.gz
Sample3_me31b_flag,/home/crystal/scratch/Me31B_Fmr1_KD_library1/demultiplex/ultraplex_demux_Sample3_me31b_flag.fastq.gz
Sample4_me31b_flag_fmr1_rnai,/home/crystal/scratch/Me31B_Fmr1_KD_library1/demultiplex/ultraplex_demux_Sample4_me31b_flag_fmr1_rnai.fastq.gz
```

An example commmand can be found in
```bash
~/scratch/CLIP-seq-tutorial/scripts/nextflow_run.sh
```

If you are running the command for the first time, you need to first generate the genome index

```diff
# replace the "--star_index" with "--save_index"
- --star_index '/home/crystal/scratch/genome/STAR_index/STAR_dmel-all-chromosome-r6.61'
+ --save_index true
```

For any subsequent runs with genome index generated, you may use the provided script directly

To submit a job on the server
```bash
# submit a job
sbatch nextflow_run.sh
# check the status of the job (this will also output the job id)
squeue -u $USER
# to cancel a submitted job
scancel <job-id>  
```

After running the command, it will create many folders containing the analysis results, `xlinks` folder contains the crosslink sites in BED file format, and this is the file we will be using for all of the downstream analysis.

3. Identify peaks from crosslink sites using Clippy
An example commmand can be found in
```bash
~/scratch/CLIP-seq-tutorial/scripts/call_peaks_clippy_run.sh
```

4. To segment the genome into genomic regions (required for PEKA)
An example commmand can be found in
```bash
~/scratch/CLIP-seq-tutorial/scripts/icount_run.sh
```

5. To identify motifs using PEKA
An example commmand can be found in
```bash
~/scratch/CLIP-seq-tutorial/scripts/peka_run.sh
```






   
