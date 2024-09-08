nextflow.enable.dsl=2

params.out = "$launchDir/output"

process downloadFile {
	publishDir params.out, mode: "copy", overwrite: true
	output:
	path "batch1.fasta"
	"""
	wget http://tinyurl.com/cqbatch1 -O batch1.fasta
	"""

}

process countSequences {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "numseq*"
  """
  grep "^>" $infile | wc -l > numseqs.txt
  """
}

process splitSequences {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "seq_*.fasta"
  """
  split -d -l 2 --additional-suffix .fasta $infile seq_
  """
}

process countBases {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}.basecount"
  """
  grep -v "^>" $infile | wc -m > ${infile.getSimpleName()}.basecount
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
  grep -o "GCCGCG" $infile | wc -l >> ${infile.getSimpleName()}.repeatcount
  """
}

process makeReport {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "finalcount.csv"
  """
  cat * > count.csv
  echo "# Sequence number, repeats" > finalcount.csv
  cat count.csv >> finalcount.csv
  """
}

workflow {
	downloadFile | splitSequences | flatten | countRepeats | collect | makeReport  
}