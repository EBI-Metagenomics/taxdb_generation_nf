
process REMOVE_EMPTY_PHYLA {

    label 'process_single'
    publishDir "${params.outdir}/${label}/${version}/", mode: 'copy'
    
    input:
    path taxid
    val version
    val label

    output:
    path ("*-tax.txt"), emit: tax

    script:
    """
    grep -v "p__;" $taxid > ${label}-tax.txt
    """

}