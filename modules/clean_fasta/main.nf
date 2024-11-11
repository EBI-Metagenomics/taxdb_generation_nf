
process CLEAN_FASTA {

    label 'light'
    container '/hps/nobackup/rdf/metagenomics/service-team/singularity-cache/quay.io_biocontainers_seqtk:1.3.sif'
    publishDir "${params.outdir}/${label}/${version}/", mode: 'copy'

    input:
    path fasta
    path tax
    val version
    val label

    output:
    path("${label}.fasta"), includeInputs: true, emit: cleaned_fasta

    script:
    """
    case $label in

        UNITE)
            sed 's/|.*//g' $fasta > ${fasta}.clean
            grep -v '^#' $tax | cut -f1 > ${label}.idlst
            seqtk subseq ${fasta}.clean ${label}.idlst > ${label}_subseq.fasta
            sed 's/NN*/N/g' ${label}_subseq.fasta > ${label}.fasta
        ;;
        
        ITSone)
            sed "s/|ITS1 located by ENA annotation,.*//g" $fasta > ${fasta}_temp.clean
            sed 's/ /_/g' ${fasta}_temp.clean > ${fasta}.clean
            grep -v '^#' $tax | cut -f1 > ${label}.idlst
            seqtk subseq ${fasta}.clean ${label}.idlst > ${label}_temp.fasta
            sed 's/ /_/g' ${label}_temp.fasta > ${label}.fasta

        ;;

        SILVA-SSU | SILVA-LSU)
            grep -v '^#' $tax | cut -f1 > ${label}.idlst
            seqtk subseq $fasta ${label}.idlst > ${label}.fasta
        ;;

        PR2)
            echo "No cleaning necessary."
        ;;

        *)
            echo "Incorrect reference db label"
            exit 1
        ;;
        
    esac
    """

}