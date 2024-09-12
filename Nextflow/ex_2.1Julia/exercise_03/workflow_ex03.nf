nextflow.enable.dsl = 2

params.url = null
// params.url = "https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/sequences.sam"
params.fileloc = null
params.out = "$launchDir/output"
params.store = "$launchDir/datastore"
params.codons = "$launchDir/codons.txt"

process downloadFile {
	storeDir params.store
	input:
		val url
	output:
		path "samfile.sam"
	"""
	wget $url -O samfile.sam
	"""
}

process makeFasta {
	publishDir params.out, mode:"copy", overwrite:true
	input:
		path samfile
	output:
		path "seq_*.fasta"
	// the split command needs the - before seq to know the input is piped in
	"""
	grep -v "@" $samfile | cut -f 1,10 | sed "s/^/>/" | tr '\t' '\n' | split -d -l 2 - seq_ --additional-suffix=.fasta
	"""
}

process countStart {
	publishDir params.out, mode:"copy", overwrite: true
	input: 
		path infile
	output:
		path "${infile.getSimpleName()}_count_start_codon.txt"
	// this process only counts start codons
	"""
	grep -o "ATG" $infile | wc -l > ${infile.getSimpleName()}_count_start_codon.txt
	"""
}

process countCodon {
	publishDir params.out, mode: "copy", overwrite: true
	input:
		tuple path(sequence), val(codon)
	output:
		path "${sequence.getSimpleName()}_${codon}_counts.txt"
	// this process counts all start and end codons, including start codons
	"""
	echo -n "$sequence, $codon, " >> ${sequence.getSimpleName()}_${codon}_counts.txt
	grep -o $codon $sequence | wc -l >> ${sequence.getSimpleName()}_${codon}_counts.txt
	"""
}

process summary {
	publishDir params.out, mode:"copy", overwrite: true
	input:
		path infile
	output:
		path "summary.csv"
	"""
	cat * | sed 's/\\.fasta//g' >> summary.csv
	
	"""
}

workflow {
// easy solution can be uncommented, only counting start codons:
// downloadFile | makeFasta | flatten | countStart | collect | summary
	if (params.url != null && params.fileloc == null) {
		fastaChannel = downloadFile(params.url) | makeFasta | flatten 
	} else if (params.url == null && params.fileloc != null) {
		fastaChannel = Channel.fromPath(params.fileloc) | makeFasta | flatten
	} else {
		print "Error: please provide either --url or --fileloc"
		System exit (0)
	}
codonChannel = Channel.fromPath(params.codons).splitText().map { it.trim() }
fastaChannel.combine(codonChannel) | countCodon | collect | summary
}

