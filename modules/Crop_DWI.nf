process Crop_DWI {
    cpus 1
    label 'big_mem'

    input:
    set sid, file(dwi), file(b0), file(b0_mask) from dwi_and_b0_mask_b0_for_crop

    output:
    set sid, "${sid}__dwi_cropped.nii.gz",
        "${sid}__b0_mask_cropped.nii.gz" into dwi_mask_for_normalize
    set sid, "${sid}__b0_mask_cropped.nii.gz" into mask_for_resample
    file "${sid}__b0_cropped.nii.gz"

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_crop_volume.py $dwi ${sid}__dwi_cropped.nii.gz -f\
        --output_bbox dwi_boundingBox.pkl -f
    scil_crop_volume.py $b0 ${sid}__b0_cropped.nii.gz\
        --input_bbox dwi_boundingBox.pkl -f
    scil_crop_volume.py $b0_mask ${sid}__b0_mask_cropped.nii.gz\
        --input_bbox dwi_boundingBox.pkl -f
    scil_image_math.py convert ${sid}__b0_mask_cropped.nii.gz ${sid}__b0_mask_cropped.nii.gz --data_type uint8 -f
    """
}