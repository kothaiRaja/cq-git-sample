nextflow.enable.dsl=2

params.out = "$launchDir/output"
params.url = "https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/sequences.sam" // Raw file URL for downloading
params.temp = "${launchDir}/downloads" // Temporary directory for intermediate files

process downloadFile {
    publishDir params.out, mode: "copy", overwrite: true

    output:
        path "seq1.SAM"

    storeDir params.temp // Stores intermediate files in this directory

    script:
    """
    wget ${params.url} -O seq1.SAM 
    """
}

process filterAndExtract {
    input:
        path samFile 

    output:
        path 'sequences_filtered.txt'
	"""
	grep -v "^@" ${samFile} | awk '{print \$1 "\\n" \$10}' > sequences_filtered.txt
	"""
}


process splitSequence {
	
	publishDir params.out, mode: "copy", overwrite: true
	
	input: 
		path infile //Declare a path input and name it 'infile'
	output:
		path "splitseq_*" //Output files matching 'splitseq_*'
	"""
	split -d -l 2 --additional-suffix .fasta $infile splitseq_
	"""
	
}

process countRepeats {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}.repeatcount"
  """
  echo -n "${infile.getSimpleName()}" | cut -z -d "_" -f 2 > ${infile.getSimpleName()}.repeatcount
  echo -n ", " >> ${infile.getSimpleName()}.repeatcount
  grep -o "ATG" $infile | wc -l >> ${infile.getSimpleName()}.repeatcount
  """
}
workflow {
    downloadFile | filterAndExtract | splitSequence | flatten | countRepeats
}