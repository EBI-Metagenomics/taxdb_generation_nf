
process GET_TAX_LINEAGE {

    label 'heavy'

    input:
    path fasta
    path taxdump
    val version
    val label

    output:
    path("*tax_lineage.txt"), emit: tax_lineage

    """
    grep ">" $fasta | cut -d"|" -f2 > itsonedb.sliced_taxids
    unzip $taxdump 
    python /hps/software/users/rdf/metagenomics/service-team/users/chrisata/scripts_taxdb_nf/bin/get_tax_lineage.py -t itsonedb.sliced_taxids -d taxa.txt -o itsonedb_tax_lineage.txt
    """

}