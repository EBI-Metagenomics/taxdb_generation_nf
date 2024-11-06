#!/usr/bin/env python

import argparse
import gzip

from Bio import SeqIO

def load_mapping(tsv_file):
    """
    Load mapping of UniRef90 proteins to Rhea IDs from a TSV file.
    Returns a dictionary with RepID as the key and RheaID as the value.
    """
    mapping = {}
    with open(tsv_file, 'r') as file:
        for line in file:
            rep_id, rhea_id = line.strip().split('\t')
            rhea_id = " ".join(sorted(set(rhea_id.split())))
            mapping[rep_id] = rhea_id
    return mapping

def filter_fasta(input_fasta, output_fasta, mapping):
    """
    Filter the FASTA file based on the mapping and add RheaID to the header.
    Supports both regular and gzipped FASTA files.
    """
    with open(output_fasta, 'w') as out_handle:
        if input_fasta.endswith('.gz'):
            with gzip.open(input_fasta, 'rt') as in_handle:
                for record in SeqIO.parse(in_handle, "fasta"):
                    rep_id = record.id.split("_")[1]
                    if rep_id in mapping:
                        rhea_id = mapping[rep_id]
                        record.description += f' RheaID="{rhea_id}"'
                        SeqIO.write(record, out_handle, "fasta")
        else:
            for record in SeqIO.parse(input_fasta, "fasta"):
                rep_id = record.description.split("RepID=")[1].split()[0]
                if rep_id in mapping:
                    rhea_id = mapping[rep_id]
                    record.description += f' RheaID="{rhea_id}"'
                    SeqIO.write(record, out_handle, "fasta")

def main():
    parser = argparse.ArgumentParser(description="Filter FASTA by RepID and add RheaID to the header.")
    parser.add_argument('input_fasta', type=str, help='Input FASTA file to be cleaned (can be .fasta or .fasta.gz).')
    parser.add_argument('mapping_file', type=str, help='TSV file mapping UniRef90 proteins to Rhea IDs.')
    parser.add_argument('output_fasta', type=str, help='Output FASTA file with filtered records.')
    
    args = parser.parse_args()
    
    mapping = load_mapping(args.mapping_file)
    
    filter_fasta(args.input_fasta, args.output_fasta, mapping)

if __name__ == '__main__':
    main()
