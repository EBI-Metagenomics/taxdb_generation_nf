
import groovy.json.JsonOutput

process METADATA_LOG {

    label 'light'

    output:
    path("log.txt"), emit: log

    """
    dt=\$(date)
    echo 'params:\t${JsonOutput.toJson(params)}' > log.txt
    echo "date:\t\$dt" >> log.txt
    """

}