process Crop_T1 {
    cpus params.processes_cpus ?: params.process_crop_t1

    input:
    tuple val(sid), path(t1), path(t1_mask) // from t1_and_mask_for_crop

    output:
    tuple val(sid), path("*__t1_bet_cropped.nii.gz"), path("*__t1_bet_mask_cropped.nii.gz")
        // into t1_and_mask_for_reg

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_crop_volume.py $t1 ${sid}__t1_bet_cropped.nii.gz\
        --output_bbox t1_boundingBox.pkl -f
    scil_crop_volume.py $t1_mask ${sid}__t1_bet_mask_cropped.nii.gz\
        --input_bbox t1_boundingBox.pkl -f
    scil_image_math.py convert ${sid}__t1_bet_mask_cropped.nii.gz ${sid}__t1_bet_mask_cropped.nii.gz --data_type uint8 -f
    """
}