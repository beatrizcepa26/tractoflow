process Register_Freesurfer {
    cpus params.processes_cpus ?: params.process_register_freesurfer

    input:
    tuple val(sid), path(aparc), path(wmparc), path(t1), path(affine),
        path(warp)

    output:
    tuple val(sid), path("${sid}__aparc_warped.nii.gz"), path("${sid}__wmparc_warped.nii.gz"), emit: labels_for_segmentation

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    export ANTS_RANDOM_SEED=1234
    antsApplyTransforms -d 3 -i $aparc -r ${sid}__t1_warped.nii.gz \
        -o ${sid}__aparc_warped.nii.gz -n NearestNeighbor \
        -t ${warp} ${affine}
    antsApplyTransforms -d 3 -i $wmparc -r ${sid}__t1_warped.nii.gz \
        -o ${sid}__wmparc_warped.nii.gz -n NearestNeighbor \
        -t ${warp} ${affine}
    """
}