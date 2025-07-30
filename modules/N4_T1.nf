process N4_T1 {

    input:
    tuple val(sid), path(t1)

    output:
    tuple val(sid), path("*__t1_n4.nii.gz"), emit:  t1_for_resample

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