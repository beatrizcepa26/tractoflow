process Bet_DWI {

    label 'big_mem'

    input:
    tuple val(sid), path(dwi), path(bval), path(bvec) //from dwi_gradients_for_bet

    output:
    tuple val(sid), path("*__b0_bet.nii.gz"), path("*__b0_bet_mask.nii.gz"), emit: b0_and_mask_for_crop
    tuple val(sid), path("*__dwi_bet.nii.gz"), path("*__b0_bet.nii.gz"), \
        path("*__b0_bet_mask.nii.gz"), emit: dwi_b0_b0_mask_for_n4
    path("*__b0_no_bet.nii.gz")

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_extract_b0.py $dwi $bval $bvec ${sid}__b0_no_bet.nii.gz --mean\
            --b0_thr $params.b0_thr_extract_b0 --force_b0_threshold
    bet ${sid}__b0_no_bet.nii.gz ${sid}__b0_bet.nii.gz -m -R -f $params.bet_dwi_final_f
    scil_image_math.py convert ${sid}__b0_bet_mask.nii.gz ${sid}__b0_bet_mask.nii.gz --data_type uint8 -f
    mrcalc $dwi ${sid}__b0_bet_mask.nii.gz -mult ${sid}__dwi_bet.nii.gz -quiet -nthreads 1
    """
}