process Extract_SH_Fitting_Shell {


    input:
    tuple val(sid), path(dwi), path(bval), path(bvec)\
        //from dwi_and_grad_for_extract_sh_fitting_shell

    output:
    tuple val(sid), path("*__dwi_sh_fitting.nii.gz"), path("*__bval_sh_fitting"),
        path("*__bvec_sh_fitting") 
        //into dwi_and_grad_for_sh_fitting

    //when:
    //params.sh_fitting

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_dwi_extract_shell.py $dwi \
        $bval $bvec $params.sh_fitting_shells ${sid}__dwi_sh_fitting.nii.gz \
        ${sid}__bval_sh_fitting ${sid}__bvec_sh_fitting -t $params.dwi_shell_tolerance -f
    """
}