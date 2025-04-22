process Register_Freesurfer {
    cpus 1

    input:
    set sid, file(aparc), file(wmparc), file(t1), file(affine),
        file(warp) from labels_mat_for_reg

    output:
    set sid, "${sid}__aparc_warped.nii.gz", "${sid}__wmparc_warped.nii.gz" \
        into labels_for_segmentation

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