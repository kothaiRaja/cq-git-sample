nextflow.enable.dsl = 2

//define all the parameters

params.accession = "SRR390728" 
params.out = "${launchDir}/output"
params.store = "${launchDir}/cache"

//writing all the processes

process downloadsraFiles {
	storeDir params.store
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3" 
	input:
		val infile_nos
	output:
		path infile_nos
	"""
	prefetch $infile_nos 
	"""
		
}

process convert_to_FASTQ{
	publishDir params.out, mode: "copy", overwrite: true
	storeDir params.store
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
	input:
		path infile_nos
	output:
		path "*.fastq"
	"""
	fasterq-dump $infile_nos --split-3 
	"""
}

process stats{
	publishDir params.out, mode: "copy", overwrite: true
	input: 
		path infile_nos
	output:
		path "${infile_nos.baseName}.stats"
	container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27heb79e2c_4"
	"""
	fastqutils stats $infile_nos > ${infile_nos.baseName}.stats
	"""
}

workflow {
	prefetch=downloadsraFiles(Channel.from(params.accession))
	convert= convert_to_FASTQ(prefetch)
	stat=stats(convert)

}