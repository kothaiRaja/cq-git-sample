nextflow.enable.dsl=2

params.out = "$launchDir/output"

process downloadFile {
	publishDir params.out, mode: "copy", overwrite: true
	output:
	path "blub.fasta"
	"""
	wget http://tinyurl.com/cqbatch1 -O blub.fasta
	"""
}
process countSequences {
	publishDir "/home/kothai/cq-git-sample/Nextflow", mode: "copy", overwrite: true
	input: 
		path infile
	output:
	path "numseq.txt"
	"""
	grep "^>" $infile | wc -l > numseq.txt
	"""
}

workflow {
	downloadFile | countSequences
}