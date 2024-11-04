import argparse
import gzip

from Bio import SeqIO, Entrez
import taxoniq


Entrez.email = "sofia@ebi.ac.uk"

def is_virus_taxoniq(tax_id):
    taxon = taxoniq.Taxon(tax_id)
    if taxon.ranked_lineage:
        for t in taxon.ranked_lineage:
            if t.rank.name == "superkingdom" and t.scientific_name == "Viruses":
                return True
    else:
        return False


def is_virus_entrez(taxid):
    handle = Entrez.efetch(db="taxonomy", id=taxid, retmode="xml")
    records = Entrez.read(handle)
    handle.close()

    lineage = records[0]["Lineage"]
    try:
        if lineage.split("; ")[0] == "Viruses":
            return True
        else:
            return False
    except:
        print(f"Error while processing {taxid} with Entrez!")


def filter_fasta(in_handle, out_handle, err_handle):
    """
    Filter the FASTA file based on the TaxID.
    Supports both regular and gzipped FASTA files.
    """
    for record in SeqIO.parse(in_handle, "fasta"):
        tax_id = record.description.split("TaxID=")[1].split()[0]
        try:
            try:
                kingdom_name = is_virus_taxoniq(tax_id)
            except KeyError:
                kingdom_name = is_virus_entrez(tax_id)
            if not kingdom_name:
                SeqIO.write(record, out_handle, "fasta")
        except Exception as e:
            err_handle.write(f"Error while processing {tax_id}: {e}")

def main(input_fasta, output_fasta):
    with open(output_fasta, 'w') as out_handle, open("failed.txt", "w") as err_handle:
        if input_fasta.endswith('.gz'):
            with gzip.open(input_fasta, 'rt') as in_handle:
                filter_fasta(in_handle, out_handle, err_handle)
        else:
            filter_fasta(input_fasta, out_handle, err_handle)

def main():
    parser = argparse.ArgumentParser(description="Filter FASTA by RepID and add RheaID to the header.")
    parser.add_argument('input_fasta', type=str, help='Input FASTA file to be cleaned (can be .fasta or .fasta.gz).')
    parser.add_argument('output_fasta', type=str, help='Output FASTA file with filtered records.')
    
    args = parser.parse_args()
    
    main(args.input_fasta, args.output_fasta)

if __name__ == '__main__':
    main()
