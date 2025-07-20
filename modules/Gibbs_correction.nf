process Gibbs_correction {
    cpus params.processes_cpus ?: params.process_gibbs_correction

    input:
    tuple val(sid), val(rev), path(dwi)

    output:
    path "${sid}_${task.process}_dstat.*"
    tuple val(sid), val(rev), path("${sid}_${rev}dwi_gibbs_corrected.nii.gz"), emit: dwi_gibbs_for_mix

    script:
    """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    mrdegibbs $dwi ${sid}_${rev}dwi_gibbs_corrected.nii.gz -nthreads $task.cpus
    """
}