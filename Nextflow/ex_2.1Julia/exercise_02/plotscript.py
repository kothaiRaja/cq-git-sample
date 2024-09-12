import sys
import pandas as pd
import matplotlib.pyplot as plt

# To run this file in Nextflow, must use this layout:
# python $projectdir/plotscript.py summaryfilename figurename

counts = pd.read_csv(sys.argv[1], header=None)
counts[2]=counts[1]/counts[1].sum()
print(counts)

plt.bar(counts[0], counts[2])
plt.xlabel("Dinucleotide")
plt.savefig(sys.argv[2])