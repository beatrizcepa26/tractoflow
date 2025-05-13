process Crop_DWI {
    cpus 1
    label 'big_mem'

    input:
    tuple val(sid), path(dwi), path(b0), path(b0_mask) // from dwi_and_b0_mask_b0_for_crop

    output:
    tuple val(sid), path("*__dwi_cropped.nii.gz"), path("*__b0_mask_cropped.nii.gz") //into dwi_mask_for_normalize
    tuple val(sid), path("*__b0_mask_cropped.nii.gzi") // into mask_for_resample
    path("*__b0_cropped.nii.gz")

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