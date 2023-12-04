
process PR2_PROCESS_TAX {

    label 'light'

    input:
    publishDir "${params.outdir}/${label}/${version}/", mode: 'copy'

    path tax
    path tax_header
    val version
    val label

    output:
    path("PR2-tax.txt"), emit: tax

    """
    sed 's/;/\t/g' $tax > tab-tax.txt
    python /hps/software/users/rdf/metagenomics/service-team/users/chrisata/scripts_taxdb_nf/bin/pr2_process_tax.py -t tab-tax.txt -o processed_tax.txt
    cat $tax_header processed_tax.txt > ${label}-tax.txt
    """

}