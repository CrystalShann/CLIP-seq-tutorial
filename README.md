# CLIP-seq-tutorial

This tutorial is intended for processing of iiCLIP data following nf-core/CLIP-seq pipeline


## Clone the Repository

To clone this repository onto your local machine, run the following command in your terminal:

```bash
git clone https://github.com/CrystalShann/CLIP-seq-tutorial.git
```

## Download Drosophila reference genome and genome annotation files

1. Navigate to [Ensemble](https://ftp.ensembl.org/pub/release-113/fasta/drosophila_melanogaster/)

2. Download the reference genome

```bash
wget https://ftp.ensembl.org/pub/release-113/fasta/drosophila_melanogaster/dna/Drosophila_melanogaster.BDGP6.46.dna_rm.toplevel.fa.gz
```

3. Download the GTF file; this is a text file that describes genes and transcripts annotation for a genome

``` bash
wget https://ftp.ensembl.org/pub/release-113/gtf/drosophila_melanogaster/Drosophila_melanogaster.BDGP6.46.113.gtf.gz
```

## List of softwares required for running CLIP-seq analysis

1. [nf-core/clipseq](https://nf-co.re/clipseq/1.0.0/)

This is a modular bioinformatics pipeline that identifies crosslink sites for iCLIP data. This will output crosslink sites in BED file format


2. [Clippy](https://github.com/ulelab/clippy)

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
<username>@cedar.computecanda.ca
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
pip install ultraplex
# activate the environment every time you want to use it, the above installation steps only needs to be done once 
source ~/envs/ultraplex/bin/activate 
```



   
