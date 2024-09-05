#!/bin/bash -ue
grep "^>" blub.fasta | wc -l > numseq.txt
