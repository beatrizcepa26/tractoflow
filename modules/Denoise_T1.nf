process Denoise_T1 {
    cpus params.processes_cpus ?: params.processes_denoise_t1

    input:
    tuple val(sid), path(t1)

    output:
    path "${sid}_${task.process}_dstat.*"
    tuple val(sid), path("*__t1_denoised.nii.gz"), emit: t1_for_mix_n4

    script:
    """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_run_nlmeans.py $t1 ${sid}__t1_denoised.nii.gz 1 \
        --processes $task.cpus -f
    """
}