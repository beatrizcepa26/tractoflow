process Extract_FODF_Shell {
    cpus 3
    label 'big_mem'

    input:
    set sid, file(dwi), file(bval), file(bvec)\
        from dwi_and_grad_for_extract_fodf_shell

    output:
    set sid, "${sid}__dwi_fodf.nii.gz", "${sid}__bval_fodf",
        "${sid}__bvec_fodf" into\
        dwi_and_grad_for_fodf

    script:
    if (params.fodf_shells)
      """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_extract_dwi_shell.py $dwi \
          $bval $bvec $params.fodf_shells ${sid}__dwi_fodf.nii.gz \
          ${sid}__bval_fodf ${sid}__bvec_fodf -t $params.dwi_shell_tolerance -f
      """
    else
      """
      export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
      export OMP_NUM_THREADS=1
      export OPENBLAS_NUM_THREADS=1

      shells=\$(cut -d ' ' --output-delimiter=\$'\\n' -f 1- $bval | \
      awk -F' ' '{v=int(\$1)}{if(v>=$params.min_fodf_shell_value|| \
      v<=$params.b0_thr_extract_b0)print v}' | uniq)

      scil_extract_dwi_shell.py $dwi \
        $bval $bvec \$shells ${sid}__dwi_fodf.nii.gz \
        ${sid}__bval_fodf ${sid}__bvec_fodf -t $params.dwi_shell_tolerance -f
      """
}