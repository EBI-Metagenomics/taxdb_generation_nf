
process REMOVE_EMPTY_PHYLA {

    label 'light'
    publishDir "${params.outdir}/${label}/${version}/", mode: 'copy'
    
    input:
    path taxid
    val version
    val label

    output:
    path ("*-tax.txt"), emit: tax

    """
    grep -v "p__;" $taxid > ${label}-tax.txt
    """

}