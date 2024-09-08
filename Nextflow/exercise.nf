//Written at start of nexrflow script, that enables nextflow version dsl=2 to run
//The line nextflow.enable.dsl=2 enables Nextflow's DSL 2 syntax, which is more flexible and powerful than the older DSL 1.

nextflow.enable.dsl=2

//defines a parameter params.out that specifies the output directory path for the workflow.

params.out = "$launchDir/output"
params.url = "http://tinyurl.com/cqbatch1"

//First process is to download the file. 
//publishDir: This directive specifies where the output of the process should be saved.
//params.out: This parameter defines the directory where the output will be copied. You might have previously defined params.out as "$launchDir/output" or passed it via the command line.
//mode: "copy": This option ensures that the output file will be physically copied to the specified directory (params.out).
//overwrite: true: This option allows overwriting of files if they already exist in the params.out directory.

//make url to download configurable (with something like 	${params.url}

process downloadFile {
	publishDir params.out, mode: "copy", overwrite: true
	output:
		path "seq.fasta"
	"""
	wget ${params.url} -O seq.fasta
	"""
}

//To split the sequences, we can use the command split sequence. In this workflow we need command split. Look for man split (manual for split) and look for proper extension. Here we need input file and output file. 

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

//Now we are going to count the G's and C's from the sequences which are in seperate files. 

process countRepeats {
	publishDir params.out, mode: "copy", overwrite: true
	input: 
		path infile
	output:
	path "${infile.getSimpleName()}_GCcount.txt" //infile.getSimpleName(): This method extracts just the file name (without the path or extension) of the input file.

//The output file will be named based on the input file's base name, with the suffix _GCcount.txt.
//For example, if the input file is sequence1.fasta, the output will be sequence1_GCcount.txt.
//"[GC]": A regular expression pattern that matches either "G" or "C". The square brackets ([]) define a character set, so it matches any occurrence of "G" or "C".

	"""
	grep -o "[GC]" ${infile} | wc -l > ${infile.getSimpleName()}_GCcount.txt
	"""
}

workflow {
	downloadFile | splitSequence | flatten | countRepeats
}