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

from Bio import Entrez
import pyfastx
import taxoniq

# Global cache to store TaxID search results
taxid_cache = {}

def is_virus_taxoniq(tax_id):
    """
    Check if taxa id is virus using faster taxoniq search in local, 
    indexed, compressed copy of the NCBI taxonomy database
    """
    taxon = taxoniq.Taxon(tax_id)
    if taxon.ranked_lineage:
        highest_taxon = taxon.ranked_lineage[-1]
        if highest_taxon.rank.name == "superkingdom":
            return highest_taxon.scientific_name == "Viruses"
    raise ValueError("No information about the lineage in taxoniq")

def is_virus_entrez(taxid):
    """
    Check if taxa id is virus using slower approach with Entrez querying
    """
    handle = Entrez.efetch(db="taxonomy", id=taxid, retmode="xml")
    records = Entrez.read(handle)
    handle.close()

    lineage = records[0]["Lineage"]
    highest_taxon = lineage.split("; ")[0]
    return highest_taxon == "Viruses"

def is_virus(tax_id):
    """
    Wrapper function that checks cache before querying taxoniq or Entrez.
    Caches the result to avoid redundant queries.
    """
    if tax_id in taxid_cache:
        return taxid_cache[tax_id]

    is_viral = False
    try:
        is_viral = is_virus_taxoniq(tax_id)
    except (KeyError, ValueError):
        # If taxoniq fails, fallback to Entrez
        is_viral = is_virus_entrez(tax_id)

    # Cache the result
    taxid_cache[tax_id] = is_viral
    return is_viral

def filter_fasta(fasta, err_handle):
    """
    Filter viral proteins from FASTA using TaxID field.
    Returns a list of records that are non-viral.
    """
    output_buffer = []
    
    for seq in fasta:
        try:
            tax_id = seq.description.split("TaxID=")[1].split()[0]
            is_viral_protein = is_virus(tax_id)
            if not is_viral_protein:
                output_buffer.append((seq))
        except Exception as e:
            err_handle.write(f"Error while processing {tax_id}: {e}\n")
    
    return output_buffer

def processing_handle(input_fasta, output_fasta):
    """
    Enable processing of both regular and gzipped FASTA files.
    Filter the data and then write all output at once at the end.
    """
    with open("failed.txt", "w") as err_handle:
        fasta = pyfastx.Fasta(input_fasta)
        output_buffer = filter_fasta(fasta, err_handle)

    with open(output_fasta, 'w') as out_handle:
        for seq in output_buffer:
            out_handle.write(seq.raw)

def main():
    parser = argparse.ArgumentParser(description="Remove viral proteins from FASTA using TaxID field")
    parser.add_argument('input_fasta', type=str, help='Input FASTA file to be cleaned (can be .fasta or .fasta.gz)')
    parser.add_argument('output_fasta', type=str, help='Output FASTA file with filtered records')

    args = parser.parse_args()
    
    processing_handle(args.input_fasta, args.output_fasta)

if __name__ == '__main__':
    main()
