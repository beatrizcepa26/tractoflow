process Normalize_DWI {
    cpus 3
    label 'big_mem'

    input:
    tuple val(sid), path(dwi), path(mask), path(bval), path(bvec) //from dwi_mask_grad_for_normalize

    output:
    tuple val(sid), path("*__dwi_normalized.nii.gz"), emit: dwi_for_resample //, dwi_for_test_resample
    path("*_fa_wm_mask.nii.gz")

    script:
    if (params.dti_shells)
      """
      export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
      export OMP_NUM_THREADS=1
      export OPENBLAS_NUM_THREADS=1
      scil_extract_dwi_shell.py $dwi \
          $bval $bvec $params.dti_shells dwi_dti.nii.gz \
          bval_dti bvec_dti -t $params.dwi_shell_tolerance
      scil_compute_dti_metrics.py dwi_dti.nii.gz bval_dti bvec_dti --mask $mask\
          --not_all --fa fa.nii.gz --force_b0_threshold
      mrthreshold fa.nii.gz ${sid}_fa_wm_mask.nii.gz -abs $params.fa_mask_threshold -nthreads 1
      dwinormalise individual $dwi ${sid}_fa_wm_mask.nii.gz ${sid}__dwi_normalized.nii.gz\
          -fslgrad $bvec $bval -nthreads 1
      """
    else
      """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1

        shells=\$(cut -d ' ' --output-delimiter=\$'\\n' -f 1- $bval | awk -F' ' '{v=int(\$1)}{if(v<=$params.max_dti_shell_value)print v}' | uniq)

        scil_extract_dwi_shell.py $dwi \
            $bval $bvec \$shells dwi_dti.nii.gz \
            bval_dti bvec_dti -t $params.dwi_shell_tolerance
        scil_compute_dti_metrics.py dwi_dti.nii.gz bval_dti bvec_dti --mask $mask\
            --not_all --fa fa.nii.gz --force_b0_threshold
        mrthreshold fa.nii.gz ${sid}_fa_wm_mask.nii.gz -abs $params.fa_mask_threshold -nthreads 1
        dwinormalise individual $dwi ${sid}_fa_wm_mask.nii.gz ${sid}__dwi_normalized.nii.gz\
            -fslgrad $bvec $bval -nthreads 1
      """

}