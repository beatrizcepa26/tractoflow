process Resample_DWI {

    cpus params.processes_cpus ?: params.process_resample_dwi

    input:
    tuple val(sid), path(dwi), path(mask)

    output:
    tuple val(sid), path("${sid}__dwi_resampled.nii.gz"), emit: dwi_resampled_for_mix

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_resample_volume.py $dwi \
        dwi_resample.nii.gz \
        --voxel_size $params.dwi_resolution \
        --interp  $params.dwi_interpolation
    fslmaths dwi_resample.nii.gz -thr 0 dwi_resample_clipped.nii.gz
    scil_resample_volume.py $mask \
        mask_resample.nii.gz \
        --ref dwi_resample.nii.gz \
        --enforce_dimensions \
        --interp nn
    mrcalc dwi_resample_clipped.nii.gz mask_resample.nii.gz\
        -mult ${sid}__dwi_resampled.nii.gz -quiet -nthreads 1
    """
}