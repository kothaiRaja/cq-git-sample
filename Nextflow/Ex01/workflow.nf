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
	publishDir "/home/kothai/cq-git-sample/Nextflow", mode: "copy", overwrite: true
	input: 
		path infile
	output:
	path "numseq.txt"
	"""
	grep "^>" $infile | wc -l > numseq.txt
	"""
}

process splitSequences {
    publishDir params.out, mode: "copy", overwrite: true

    input: 
        path infile

    output:
        path "numseq_*"  

    script:
        """
        split -l 2 $infile numseq_  
        """
}


workflow {
	downloadFile ()
}