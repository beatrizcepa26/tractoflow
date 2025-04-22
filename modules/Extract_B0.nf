process Extract_B0 {
    cpus 3
    label 'big_mem'

    input:
    set sid, path(dwi), path(bval), path(bvec) from dwi_and_grad_for_extract_b0

    output:
    tuple value(sid), path("${sid}__b0_resampled.nii.gz") into b0_for_reg
    tuple value(sid), path("${sid}__b0_mask_resampled.nii.gz") into\
        b0_mask_for_dti_metrics,
        b0_mask_for_fodf,
        b0_mask_for_rf

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_extract_b0.py $dwi $bval $bvec ${sid}__b0_resampled.nii.gz --mean\
        --b0_thr $params.b0_thr_extract_b0 --force_b0_threshold
    mrthreshold ${sid}__b0_resampled.nii.gz ${sid}__b0_mask_resampled.nii.gz\
        --abs 0.00001 -nthreads 1
    """
}