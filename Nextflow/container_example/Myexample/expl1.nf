nextflow.enable.dsl = 2

//we are going to define all the parameters

params.storeDir = "${launchDir}/cache"
params.out = "$launchDir/output"
params.accession= "SRR16641628"

//Define the process of downloading SRA file from SRA database. 
 
process downloadsraFile {
	storeDir params.storeDir
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
	input:
		val accession
	output:
		path "$accession"
	
	"""
	prefetch $accession 
	"""
}

//fasterq-dump:
//fasterq-dump is a tool provided by the NCBI's SRA Toolkit. It is a faster and more efficient version of the older fastq-dump tool.
//Purpose: It converts an SRA file into one or more FASTQ files (depending on whether the sequencing data is single-end or paired-end).
//It handles large datasets more efficiently and can produce compressed FASTQ files with gzip

process convert_to_FASTQfiles{
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
	input:
		path accession
	output:
		path "${accession}.fastq" //Here i have some idea that it produces .fastq files so i give extension to outfile as .fastq
		
//is used to convert an SRA (Sequence Read Archive) file (specified by the accession number) into FASTQ files using the fasterq-dump tool from the SRA Toolkit.
//--split-3:
//The --split-3 option is used to handle paired-end sequencing data.
//Paired-end reads are typically stored in a single SRA file, but when converting to FASTQ, you need to split the forward and reverse reads into separate FASTQ files.
//--split-3 does the following:
//Forward reads are written to a file ending in _1.fastq.
//Reverse reads are written to a file ending in _2.fastq.
//Unpaired reads (reads that don’t have a mate) are written to a separate file ending in .fastq.	

	"""
	fasterq-dump $accession --split-3 
  
	"""
	
}

process quality_control {
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastqc%3A0.12.1--hdfd78af_0"
	input:
		path accession
	output:
		path "${accession.baseName}_fastqc.*"
	"""
	fastqc ${accession}
	"""
}

process stats {
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27heb79e2c_4"
	input:
		path accession
	output:
		path "${accession}.stats" //I dont know what kind of output file is generated and so i used wildcards
//look in https://ngsutils.org/modules/fastqutils/ and get the syntax for getting stats and i redirect the output to a new file named .stats

	"""
	fastqutils stats $accession > ${accession}.stats
	"""
}
workflow {
	prefetch = downloadsraFile(Channel.from(params.accession))
	converts = convert_to_FASTQfiles(prefetch)
	quality = quality_control(converts)

}
