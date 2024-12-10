#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2024 EMBL - European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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


def filter_fasta(in_handle, out_handle, mapping):
    """
    Filter the FASTA file based on the mapping and add RheaID to the header.
    """
    for record in SeqIO.parse(in_handle, "fasta"):
        rep_id = record.id.split("_")[1]
        if rep_id in mapping:
            rhea_id = mapping[rep_id]
            record.description += f' RheaID="{rhea_id}"'
            SeqIO.write(record, out_handle, "fasta")


def processing_handle(input_fasta, output_fasta, mapping):
    """
    Enable processing of both regular and gzipped FASTA files.
    """
    with open(output_fasta, 'w') as out_handle:
        if input_fasta.endswith('.gz'):
            with gzip.open(input_fasta, 'rt') as in_handle:
                filter_fasta(in_handle, out_handle, mapping)
        else:
            filter_fasta(input_fasta, out_handle, mapping)

def main():
    parser = argparse.ArgumentParser(description="Filter FASTA by RepID and add RheaID to the header.")
    parser.add_argument('input_fasta', type=str, help='Input FASTA file to be cleaned (can be .fasta or .fasta.gz).')
    parser.add_argument('mapping_file', type=str, help='TSV file mapping UniRef90 proteins to Rhea IDs.')
    parser.add_argument('output_fasta', type=str, help='Output FASTA file with filtered records.')
    
    args = parser.parse_args()
    
    mapping = load_mapping(args.mapping_file)
    
    processing_handle(args.input_fasta, args.output_fasta, mapping)

if __name__ == '__main__':
    main()
