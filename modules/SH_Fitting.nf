process SH_Fitting {

    input:
    tuple val(sid), path(dwi), path(bval), path(bvec)

    output:
    path("${sid}__dwi_sh.nii.gz")

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_compute_sh_from_signal.py --sh_order $params.sh_fitting_order --sh_basis $params.sh_fitting_basis $dwi $bval $bvec ${sid}__dwi_sh.nii.gz
    """
}