process Denoise_T1 {
    cpus params.processes ?: params.processes_denoise_t1

    input:
    tuple val(sid), path(t1) //from t1_for_denoise

    output:
    tuple val(sid), path("*__t1_denoised.nii.gz") // into t1_for_mix_n4

    //when:
    //params.run_t1_denoising

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_run_nlmeans.py $t1 ${sid}__t1_denoised.nii.gz 1 \
        --processes $task.cpus -f
    """
}