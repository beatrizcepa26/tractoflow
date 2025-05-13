process DTI_Metrics {
    cpus 3
    label 'big_mem'

    input:
    tuple val(sid), path(dwi), path(bval), path(bvec), path(b0_mask)
        // from dwi_and_grad_for_dti_metrics

    output:
    path("${sid}__ad.nii.gz")
    path("${sid}__evecs.nii.gz")
    path("${sid}__evecs_v1.nii.gz")
    path("${sid}__evecs_v2.nii.gz")
    path("${sid}__evecs_v3.nii.gz")
    path("${sid}__evals.nii.gz")
    path("${sid}__evals_e1.nii.gz")
    path("${sid}__evals_e2.nii.gz")
    path("${sid}__evals_e3.nii.gz")
    path("${sid}__fa.nii.gz")
    path("${sid}__ga.nii.gz")
    path("${sid}__rgb.nii.gz")
    path("${sid}__md.nii.gz")
    path("${sid}__mode.nii.gz")
    path("${sid}__norm.nii.gz")
    path("${sid}__rd.nii.gz")
    path("${sid}__tensor.nii.gz")
    path("${sid}__nonphysical.nii.gz")
    path("${sid}__pulsation_std_dwi.nii.gz")
    path("${sid}__residual.nii.gz")
    path("${sid}__residual_iqr_residuals.npy")
    path("${sid}__residual_mean_residuals.npy")
    path("${sid}__residual_q1_residuals.npy")
    path("${sid}__residual_q3_residuals.npy")
    path("${sid}__residual_residuals_stats.png")
    path("${sid}__residual_std_residuals.npy")
    tuple val(sid), path("${sid}__fa.nii.gz"), path("${sid}__md.nii.gz"), emit: fa_md_for_fodf
    tuple val(sid), path("${sid}__fa.nii.gz"), emit: fa_for_reg
        //fa_for_reg, fa_for_pft_tracking, fa_for_local_tracking_mask, fa_for_local_seeding_mask

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_compute_dti_metrics.py $dwi $bval $bvec --mask $b0_mask\
        --ad ${sid}__ad.nii.gz --evecs ${sid}__evecs.nii.gz\
        --evals ${sid}__evals.nii.gz --fa ${sid}__fa.nii.gz\
        --ga ${sid}__ga.nii.gz --rgb ${sid}__rgb.nii.gz\
        --md ${sid}__md.nii.gz --mode ${sid}__mode.nii.gz\
        --norm ${sid}__norm.nii.gz --rd ${sid}__rd.nii.gz\
        --tensor ${sid}__tensor.nii.gz\
        --non-physical ${sid}__nonphysical.nii.gz\
        --pulsation ${sid}__pulsation.nii.gz\
        --residual ${sid}__residual.nii.gz\
        -f --force_b0_threshold
    """
}
