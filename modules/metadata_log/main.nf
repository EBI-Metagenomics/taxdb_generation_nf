
import groovy.json.JsonOutput

process METADATA_LOG {

    label 'light'
    publishDir "${params.outdir}/", mode: 'copy'

    output:
    path("log.txt"), emit: log

    script:
    """
    dt=\$(date)
    echo 'params:\t${JsonOutput.toJson(params)}' > log.txt
    echo "date:\t\$dt" >> log.txt
    """

}