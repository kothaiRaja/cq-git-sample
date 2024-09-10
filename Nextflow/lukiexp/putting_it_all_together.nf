nextflow.enable.dsl = 2

params.url = "https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/sequences.sam?inline=false"
params.temp = "${launchDir}/downloads"
params.out = "${launchDir}/all2gether"

process downloadSAM {
	storeDir params.temp
	input:
		val inurl
	output:
		path "sequences.sam"
	//downlading the file with the variable params.url
	"""
	wget $inurl -O sequences.sam
	"""
}

process cleanSAM {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "cleaned_sequences.sam"
  """
  cat $infile | grep -v "^@" > cleaned_sequences.sam
  """
}


process splitSAM {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "sequence_*.fasta"
  """
  split -d -l 1 --additional-suffix .fasta $infile sequence_
  """
}

process samtoFASTA {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}_correct.fasta"
  """
  echo -n ">" > ${infile.getSimpleName()}_correct.fasta
  cat $infile | cut -f 1 >> ${infile.getSimpleName()}_correct.fasta
  cat $infile | cut -f 10 >> ${infile.getSimpleName()}_correct.fasta
  """
}

process countStart {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}_S_count.txt"
  """
  echo -n "Number of Start Codons: " > ${infile.getSimpleName()}_S_count.txt
  grep -o "ATG" $infile | wc -l >> ${infile.getSimpleName()}_S_count.txt
  """
}

workflow{
	fastafile = downloadSAM(Channel.from(params.url)) | cleanSAM | splitSAM | flatten | samtoFASTA | countStart
}

