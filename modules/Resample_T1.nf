process Resample_T1 {
    cpus params.processes_cpus ?: params.process_resample_t1

    input:
    tuple val(sid), path(t1)
    output:
    path "${sid}_${task.process}_dstat.*"
    tuple val(sid), path("*__t1_resampled.nii.gz"), emit: t1_resampled_for_mix

    script:
    """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_resample_volume.py $t1 ${sid}__t1_resampled.nii.gz \
        --voxel_size $params.t1_resolution \
        --interp  $params.t1_interpolation
    """
}