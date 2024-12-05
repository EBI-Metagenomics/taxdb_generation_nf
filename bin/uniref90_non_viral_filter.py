#!/usr/bin/env python

import argparse
import gzip

from Bio import SeqIO, Entrez
import taxoniq


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
    Check if taxa id is virus using slower approach with
    Entrez quering
    """
    handle = Entrez.efetch(db="taxonomy", id=taxid, retmode="xml")
    records = Entrez.read(handle)
    handle.close()

    lineage = records[0]["Lineage"]
    highest_taxon = lineage.split("; ")[0]
    return highest_taxon == "Viruses"


def filter_fasta(in_handle, out_handle, err_handle):
    """
    Filter viral proteins from FASTA using TaxID field.
    """
    for record in SeqIO.parse(in_handle, "fasta"):
        tax_id = record.description.split("TaxID=")[1].split()[0]
        try:
            try:
                is_viral_protein = is_virus_taxoniq(tax_id)
            except (KeyError, ValueError):
                is_viral_protein = is_virus_entrez(tax_id)
            if is_viral_protein is False:
                SeqIO.write(record, out_handle, "fasta")
        except Exception as e:
            err_handle.write(f"Error while processing {tax_id}: {e}\n")


def processing_handle(input_fasta, output_fasta):
    """
    Enable processing of both regular and gzipped FASTA files.
    """
    with open(output_fasta, 'w') as out_handle, open("failed.txt", "w") as err_handle:
        if input_fasta.endswith('.gz'):
            with gzip.open(input_fasta, 'rt') as in_handle:
                filter_fasta(in_handle, out_handle, err_handle)
        else:
            filter_fasta(input_fasta, out_handle, err_handle)

def main():
    parser = argparse.ArgumentParser(description="Remove viral proteins from FASTA using TaxID field")
    parser.add_argument('input_fasta', type=str, help='Input FASTA file to be cleaned (can be .fasta or .fasta.gz)')
    parser.add_argument('output_fasta', type=str, help='Output FASTA file with filtered records')
    
    args = parser.parse_args()
    
    processing_handle(args.input_fasta, args.output_fasta)

if __name__ == '__main__':
    main()
