process Resample_T1 {
    cpus params.processes ?: params.process_resample_t1

    input:
    tuple val(sid), path(t1) // from t1_for_resample

    output:
    tuple val(sid), path("*__t1_resampled.nii.gz") // into t1_resampled_for_mix

    //when:
    //params.run_resample_t1

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_resample_volume.py $t1 ${sid}__t1_resampled.nii.gz \
        --voxel_size $params.t1_resolution \
        --interp  $params.t1_interpolation
    """
}