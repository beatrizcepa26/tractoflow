process Extract_DTI_Shell {
    label 'big_mem'
    cpus params.process_dti_shell

    input:
    tuple val(sid), path(dwi), path(bval), path(bvec)
        //from dwi_and_grad_for_extract_dti_shell

    output:
    tuple val(sid), path("${sid}__dwi_dti.nii.gz"), path("${sid}__bval_dti"),
        path("${sid}__bvec_dti") 
        //into dwi_and_grad_for_dti_metrics, \
        // dwi_and_grad_for_rf

    script:
    if (params.dti_shells)
      """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_extract_dwi_shell.py $dwi \
          $bval $bvec $params.dti_shells ${sid}__dwi_dti.nii.gz \
          ${sid}__bval_dti ${sid}__bvec_dti -t $params.dwi_shell_tolerance -f
      """
    else
      """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1

        shells=\$(cut -d ' ' --output-delimiter=\$'\\n' -f 1- $bval | \
                awk -F' ' '{v=int(\$1)}{if(v<=$params.max_dti_shell_value)print v}' | uniq)

        scil_extract_dwi_shell.py $dwi \
          $bval $bvec \$shells ${sid}__dwi_dti.nii.gz \
          ${sid}__bval_dti ${sid}__bvec_dti -t $params.dwi_shell_tolerance -f
      """
}