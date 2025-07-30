process README {
    publishDir params.Readme_Publish_Dir
    tag "README"

    output:
    path("readme.txt")

    script:

    def list_options = "";
    params.each { key, value ->
        list_options +="$key: $value\n"
    }


    """
    echo "TractoFlow pipeline\n" >> readme.txt
    echo "Start time: $workflow.start\n" >> readme.txt
    echo "[Command-line]\n$workflow.commandLine\n" >> readme.txt
    echo "[Git Info]\n" >> readme.txt
    echo "$workflow.repository - $workflow.revision [$workflow.commitId]\n" >> readme.txt
    echo "[Options]\n" >> readme.txt
    echo "$list_options" >> readme.txt
    """
}