process Denoise_DWI {
    cpus params.processes_cpus ?: params.processes_denoise_dwi
    label 'big_mem'

    input:
    tuple val(sid), val(rev), path(dwi)

    output:
    path "${sid}_${task.process}_dstat.*"
    tuple val(sid), val(rev), path ("${sid}_${rev}dwi_denoised.nii.gz"), emit: dwi_denoised_for_mix

    script:
    // The denoised DWI is clipped to 0 since negative values
    // could have been introduced.
    """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    dwidenoise $dwi dwi_denoised.nii.gz -extent $params.extent -nthreads $task.cpus
    fslmaths dwi_denoised.nii.gz -thr 0 ${sid}_${rev}dwi_denoised.nii.gz
    """
}