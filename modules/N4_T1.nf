process N4_T1 {

    cpus params.processes_cpus ?: params.process_n4_t1

    input:
    tuple val(sid), path(t1)

    output:
    path "${sid}_${task.process}_dstat.*"
    tuple val(sid), path("*__t1_n4.nii.gz"), emit:  t1_for_resample

    script:
    """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    N4BiasFieldCorrection -i $t1\
        -o [${sid}__t1_n4.nii.gz, bias_field_t1.nii.gz]\
        -c [300x150x75x50, 1e-6] -v 1
    """
}