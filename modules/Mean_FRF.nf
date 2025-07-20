process Mean_FRF {

    publishDir params.Mean_FRF_Publish_Dir
    tag "All_FRF"
    cpus params.processes_cpus ?: params.process_mean_frf

    input:
    path(all_frf)

    output:
    path "${sid}_${task.process}_dstat.*"
    path("mean_frf.txt"), emit: mean_frf

    script:
    """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_compute_mean_frf.py $all_frf mean_frf.txt
    """
}