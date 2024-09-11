nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.accession="SRR1777174"

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

workflow {
  prefetch(Channel.from(params.accession))
}