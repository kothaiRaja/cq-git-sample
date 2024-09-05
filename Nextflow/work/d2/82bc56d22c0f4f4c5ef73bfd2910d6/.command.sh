#!/bin/bash -ue
grep "^>" batch1.fasta | wc -l > numseq.txt
