process N4_T1 {
    cpus 1

    input:
    tuple value(sid), path(t1) from t1_for_n4

    output:
    tuple value(sid), path("${sid}__t1_n4.nii.gz") into t1_for_resample, t1_for_test_resample

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    N4BiasFieldCorrection -i $t1\
        -o [${sid}__t1_n4.nii.gz, bias_field_t1.nii.gz]\
        -c [300x150x75x50, 1e-6] -v 1
    """
}