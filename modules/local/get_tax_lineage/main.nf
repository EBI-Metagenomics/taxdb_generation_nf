
process GET_TAX_LINEAGE {

    label 'process_low'

    input:
    path fasta
    path taxdump
    val version
    val label

    output:
    path("*tax_lineage.txt"), emit: tax_lineage

    script:
    """
    grep ">" $fasta | cut -d"|" -f2 > itsonedb.sliced_taxids
    unzip $taxdump 
    get_tax_lineage.py -t itsonedb.sliced_taxids -d taxa.txt -o itsonedb_tax_lineage.txt
    """

}