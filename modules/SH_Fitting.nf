process SH_Fitting {
    cpus 1

    input:
    set sid, file(dwi), file(bval), file(bvec) from dwi_and_grad_for_sh_fitting

    output:
    file "${sid}__dwi_sh.nii.gz"

    when:
    params.sh_fitting

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_compute_sh_from_signal.py --sh_order $params.sh_fitting_order --sh_basis $params.sh_fitting_basis $dwi $bval $bvec ${sid}__dwi_sh.nii.gz
    """
}