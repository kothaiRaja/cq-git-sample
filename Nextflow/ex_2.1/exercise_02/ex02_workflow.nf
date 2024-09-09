nextflow.enable.dsl = 2

params.out = "$launchDir/output"
params.species = "not_specified"
params.url = "https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/dinucleotides/homosapienscontig.fasta?inline=false"
params.pyfile = "$projectDir/plotscript.py"
params.dinucfile = "dinucleotides.txt"

process downloadFile {
	publishDir params.out, mode:"copy", overwrite:true
	output:
		path "genomeexample.fasta"
	"""
	wget ${params.url} -O genomeexample.fasta
	"""
}

process countDinucs {
	publishDir params.out, mode:"copy", overwrite:true
	input:
		tuple path(genome), val(dinuc)	
	output:
		path "*_count.txt"
	"""
	echo -n "${dinuc}, " > "${dinuc}_count.txt"
	grep -o ${dinuc} ${genome} | wc -l >> "${dinuc}_count.txt"
	"""
}

process createSummary {
	publishDir params.out, mode:"copy", overwrite:true
	input:
		path dinuccounts
	output:
		path "summary_count_dinucs.csv"
	
	"""
	cat * >> "summary_count_dinucs.csv"
	"""
}

process plot {
	publishDir params.out, mode:"copy", overwrite:true
	output:
		path "${params.species}_bargraph.png"
	input:
		path summary
	"""
	python3 $params.pyfile $summary "${params.species}_bargraph.png"
	"""
}

workflow {
DinucleotideChannel = Channel.fromPath(params.dinucfile).splitText().map { it.trim() }
DinucleotideChannel.view()
GenomeChannel = downloadFile()
GenomeChannel.view()
GenomeChannel.combine(DinucleotideChannel) | countDinucs | collect | createSummary | plot
}

