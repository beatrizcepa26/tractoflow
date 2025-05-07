process Denoise_DWI {
    cpus params.processes_denoise_dwi
    label 'big_mem'

    input:
    tuple val(sid), val(rev), path(dwi) // from dwi_for_denoise

    output:
    tuple val(sid), val(rev), path ("${sid}_${rev}dwi_denoised.nii.gz") // into dwi_denoised_for_mix

    when:
    params.run_dwi_denoising

    script:
    // The denoised DWI is clipped to 0 since negative values
    // could have been introduced.
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    dwidenoise $dwi dwi_denoised.nii.gz -extent $params.extent -nthreads $task.cpus
    fslmaths dwi_denoised.nii.gz -thr 0 ${sid}_${rev}dwi_denoised.nii.gz
    """
}