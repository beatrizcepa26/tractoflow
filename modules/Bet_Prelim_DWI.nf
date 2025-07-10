process Bet_Prelim_DWI {


    input:
    tuple val (sid), val (rev), path (dwi), path(bval), path (bvec) // file(bvec) from dwi_gradient_for_prelim_bet
    val(rev_b0_count) // from rev_b0_counter
    val(rev_dwi_count) // from rev_dwi_counter

    output:
    tuple val(sid), path ("${sid}__b0_bet_mask_dilated.nii.gz"), emit : b0_mask_for_eddy
    path "${sid}__b0_bet.nii.gz"
    path "${sid}__b0_bet_mask.nii.gz"

    //when:
    //(rev_b0_count == 0 && rev_dwi_count == 0 && params.run_eddy) || (!params.run_topup && params.run_eddy)

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_volume_math.py convert $dwi $dwi --data_type float32 -f
    scil_dwi_extract_b0.py $dwi $bval $bvec ${sid}__b0.nii.gz --mean\
        --b0_thr $params.b0_thr_extract_b0 --skip_b0_check
    bet ${sid}__b0.nii.gz ${sid}__b0_bet.nii.gz -m -R -f $params.bet_prelim_f
    scil_volume_math.py convert ${sid}__b0_bet_mask.nii.gz ${sid}__b0_bet_mask.nii.gz --data_type uint8 -f
    maskfilter ${sid}__b0_bet_mask.nii.gz dilate ${sid}__b0_bet_mask_dilated.nii.gz\
        --npass $params.dilate_b0_mask_prelim_brain_extraction -nthreads 1
    mrcalc ${sid}__b0.nii.gz ${sid}__b0_bet_mask_dilated.nii.gz\
        -mult ${sid}__b0_bet.nii.gz -quiet -force -nthreads 1
    """
}