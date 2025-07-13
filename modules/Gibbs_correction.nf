process Gibbs_correction {
    cpus params.processes_cpus ?: params.process_gibbs_correction

    input:
    tuple val(sid), val(rev), path(dwi)  //from dwi_for_gibbs

    output:
    tuple val(sid), val(rev), path("${sid}_${rev}dwi_gibbs_corrected.nii.gz") //into dwi_gibbs_for_mix

    //when:
    //    params.run_gibbs_correction

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    mrdegibbs $dwi ${sid}_${rev}dwi_gibbs_corrected.nii.gz -nthreads $task.cpus
    """
}