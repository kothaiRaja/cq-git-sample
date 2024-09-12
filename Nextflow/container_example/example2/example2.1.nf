nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.out="${launchDir}/output"
params.accession= "SRR16641606"

process prefetch {
  storeDir params.storeDir
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  input:
    val accession
  output:
    path "${accession}"
  script:
  """
  prefetch $accession
  """
}

process convert_to_fastq {
  storeDir params.storeDir
  publishDir params.storeDir
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  input:
   path accession
  output:
    path "${accession}.fastq"
  script:
  """
  fastq-dump $accession
  """
}

process stats {
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27heb79e2c_4"
	input:
		path accession
	output:
		path "*" //I dont know what kind of output file is generated and so i used wildcards
//look in https://ngsutils.org/modules/fastqutils/ and get the syntax for getting stats and i redirect the output to a new file named .stats

	"""
	fastqutils stats $accession > ${accession}.stats
	"""
}
workflow {
  variable=prefetch(Channel.from(params.accession))
  change=convert_to_fastq(variable)
  stat=stats(change)
   
}