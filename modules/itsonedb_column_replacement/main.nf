
process ITSONEDB_COLUMN_REPLACEMENT {

    label 'light'
    publishDir "${params.outdir}/${label}/${version}/", pattern : "*-tax.txt", mode: 'copy'

    input:
    path uplift
    path taxid
    path tax_header
    val version
    val label

    output:
    path("*-tax.txt"), emit: tax
    path("itsonedb.final.taxid"), emit: taxid

    """
    awk 'BEGIN {FS=OFS="\t"}NR == FNR {a[FNR] = \$B;next}{\$A = a[FNR];print \$0}' B=1 A=1 $uplift $taxid > itsonedb.final.temp.taxid
    grep -v ";p__;" $uplift > uplift.final.filt.txt
    sed 's/ /_/g' itsonedb.final.temp.taxid > itsonedb.final.taxid
    sed 's/ /_/g' uplift.final.filt.txt > uplift.final.filt.cleanedspaces.txt
    cat $tax_header uplift.final.filt.cleanedspaces.txt > ${label}-tax.txt
    """

}