process Compute_FRF {
    label 'big_mem'

    input:
    tuple val(sid), path(dwi), path(bval), path(bvec), path(b0_mask)

    output:
    tuple val(sid), path("${sid}__frf.txt"), emit: unique_frf
    path("${sid}__frf.txt"), emit: all_frf_to_collect

    script:
    if (params.set_frf)
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_compute_ssst_frf.py $dwi $bval $bvec frf.txt --mask $b0_mask\
        --fa $params.fa --min_fa $params.min_fa --min_nvox $params.min_nvox\
        --roi_radii $params.roi_radius --force_b0_threshold
        scil_set_response_function.py frf.txt $params.manual_frf ${sid}__frf.txt
        """
    else
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_compute_ssst_frf.py $dwi $bval $bvec ${sid}__frf.txt --mask $b0_mask\
        --fa $params.fa --min_fa $params.min_fa --min_nvox $params.min_nvox\
        --roi_radii $params.roi_radius --force_b0_threshold
        """
}