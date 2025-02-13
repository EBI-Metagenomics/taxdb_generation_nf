process EXTRACT_TAXDUMP {
    label 'process_single'

    input:
    path taxdump_download

    output:
    path 'nodes.dmp', emit: tax_nodes
    path 'names.dmp', emit: tax_names

    script:
    """
    tar -xvzf ${taxdump_download} nodes.dmp names.dmp
    """
}