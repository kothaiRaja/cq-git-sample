import sys


class Sequence:
    def __init__(self, name, seq):
        self.name = name
        self.seq = seq

    def get_fasta(self):
        res = [">" + self.name]
        res += [self.seq]
        return "\n".join(res)

    def __str__(self):
        res = ["Sequence with following metadata:"]
        res += ["  Name: " + self.name]
        res += ["  Sequence: " + self.seq]
        return "\n".join(res)


def split_fasta(infilename):
    res = []
    f = open(infilename, "r")
    for line in f.readlines():
        if line.startswith(">"):
            currentsequence = Sequence(line[1:].strip(), "")
        else:
            currentsequence.seq = line.strip()
            res += [currentsequence]
    f.close()
    return res


def write_sequences(sequences, prefix):
    for sequence in sequences:
        f = open(prefix + sequence.name + ".fasta", "w")
        f.write(sequence.get_fasta())
        f.close()


if __name__ == "__main__":
    infile = sys.argv[1]
    prefix = sys.argv[2]

    sequences = split_fasta(infile)
    write_sequences(sequences, prefix)
