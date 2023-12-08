#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2023 EMBL - European Bioinformatics Institute
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
#

import argparse

from Bio import SeqIO

def parse_args():

    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--fasta", required=True, type=str, help="Input fasta file")
    parser.add_argument("-u", "--uplift", required=True, type=str, help="Input uplift file")
    parser.add_argument("-o", "--output", required=True, type=str, help="Output tax file")

    args = parser.parse_args()

    _FASTA = args.fasta
    _UPLIFT = args.uplift
    _OUTPUT = args.output

    return _FASTA, _UPLIFT, _OUTPUT


def main():

    _FASTA, _UPLIFT, _OUTPUT = parse_args()

    fasta_reader = SeqIO.parse(_FASTA, "fasta")
    uplift = open(_UPLIFT, "r")
    newtax = open(_OUTPUT, "w")

    id_lst = []
    lineage = []

    for line in uplift:
        sep = line.split("\t")
        id_lst.append(sep[0])
        lineage.append(sep[1])


    for record in fasta_reader:
        id_full = (record.id).split("|")
        taxid = id_full[1]
        if taxid in id_lst:
            i = id_lst.index(taxid)
            header = "|".join(record.description.split("|")[:-1])
            newtax.write(header + "\t" + lineage[i])

    uplift.close()
    newtax.close()

if __name__ == "__main__":
    main()




