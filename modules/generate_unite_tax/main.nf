
process GENERATE_UNITE_TAX {

    label 'light'
    publishDir "${params.outdir}/${label}/${version}/", mode: 'copy'

    input:
    path fasta
    path tax_header
    val version
    val label

    output:
    path("*-tax.txt"), emit: tax

    script:
    """
    # Split the header_ids and the taxonomy into tab-separated .taxid fileq
    grep ">" $fasta | cut -d"|" -f1-2 | sed 's/|/\t/g' | sed 's/>//' | sed 's/k__/sk__Eukaryota;k__/g' > temp_unite.tax

    # Remove incertae_sedis + anything without a phylum
    sed 's/s__.*_Incertae_sedis.*/s__/g' temp_unite.tax | sed 's/g__.*_Incertae_sedis/g__/g' | sed 's/f__.*_Incertae_sedis/f__/g' | sed 's/o__.*_Incertae_sedis/o__/g' | sed 's/c__.*_Incertae_sedis/c__/g' | sed 's/p__.*_Incertae_sedis/p__/g' | sed 's/k__.*_Incertae_sedis/k__/g' | grep -v "p__;" > processed_tax.txt
    cat $tax_header processed_tax.txt > ${label}-tax.txt 
    """
}