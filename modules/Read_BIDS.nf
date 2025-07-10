process Read_BIDS {
    publishDir params.Read_BIDS_Publish_Dir
    scratch false
    stageInMode 'symlink'
    tag "Read_BIDS"
    errorStrategy { task.attempt <= 3 ? 'retry' : 'terminate' }

    input:
    file bids_folder
    file fs_folder
    file bidsignore

    output:
    file "tractoflow_bids_struct.json"

    script:
    def clean_flag = params.clean_bids ? '--clean ' : ''
    """
    scil_bids_validate.py $bids_folder tractoflow_bids_struct.json\
        --readout $params.readout $clean_flag\
        ${!fs_folder.empty() ? "--fs $fs_folder" : ""}\
        ${!bidsignore.empty() ? "--bids_ignore $bidsignore" : ""}\
        -v
    """
}
        