process EXTRACT_TAXDUMP {
    label 'process_single'

    input:
    path taxdump_link

    output:
    path 'nodes.dmp', emit: tax_nodes
    path 'names.dmp', emit: tax_names

    script:
    """
    tar -xvzf ${taxdump_link} nodes.dmp names.dmp
    """
}