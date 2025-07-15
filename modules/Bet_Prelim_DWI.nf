process Bet_Prelim_DWI {
    cpus params.processes_cpus ?: params.processes_bet_prelim_dwi

    input:
    tuple val (sid), val (rev), path (dwi), path(bval), path(bvec) 
    val(rev_b0_count)
    val(rev_dwi_count)

    output:
    tuple val(sid), path ("${sid}__b0_bet_mask_dilated.nii.gz"), emit : b0_mask_for_eddy
    path "${sid}__b0_bet.nii.gz"
    path "${sid}__b0_bet_mask.nii.gz"

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_image_math.py convert $dwi $dwi --data_type float32 -f
    scil_extract_b0.py $dwi $bval $bvec ${sid}__b0.nii.gz --mean\
        --b0_thr $params.b0_thr_extract_b0 --force_b0_threshold
    bet ${sid}__b0.nii.gz ${sid}__b0_bet.nii.gz -m -R -f $params.bet_prelim_f
    scil_image_math.py convert ${sid}__b0_bet_mask.nii.gz ${sid}__b0_bet_mask.nii.gz --data_type uint8 -f
    maskfilter ${sid}__b0_bet_mask.nii.gz dilate ${sid}__b0_bet_mask_dilated.nii.gz\
        --npass $params.dilate_b0_mask_prelim_brain_extraction -nthreads 1
    mrcalc ${sid}__b0.nii.gz ${sid}__b0_bet_mask_dilated.nii.gz\
        -mult ${sid}__b0_bet.nii.gz -quiet -force -nthreads 1
    """
}