
process MAKE_OTU_FILE {

    label 'heavy'
    publishDir "${params.outdir}/${label}/${version}/", mode: 'copy'

    input:
    path tax
    path taxid
    val version
    val label

    output:
    path("*.otu"), emit: otu

    """
    case $label in

        UNITE)
            make_otu_file.py -tx $tax -l $label
        ;;
        
        PR2)
            make_otu_file.py -tx $tax -l $label --ext_ranks
        ;;

        SILVA-SSU | SILVA-LSU | ITSone)
            make_otu_file.py -tx $tax -t $taxid -l $label
        ;;

        *)
            echo "Incorrect reference db label"
            exit 1
        ;;
        
    esac
    """

}