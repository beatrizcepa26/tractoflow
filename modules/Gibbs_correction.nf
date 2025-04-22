process Gibbs_correction {
    cpus params.processes_denoise_dwi

    input:
    set sid, val(rev), file(dwi)  from dwi_for_gibbs

    output:
    set sid, val(rev), "${sid}_${rev}dwi_gibbs_corrected.nii.gz" into\
        dwi_gibbs_for_mix

    when:
        params.run_gibbs_correction

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    mrdegibbs $dwi ${sid}_${rev}dwi_gibbs_corrected.nii.gz -nthreads $task.cpus
    """
}