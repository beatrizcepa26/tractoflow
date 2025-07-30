process Register_T1 {

    input:
    tuple val(sid), path(t1), path(t1_mask), path(fa), path(b0)

    output:
    tuple val(sid), path("${sid}__t1_warped.nii.gz"), emit: t1_for_seg
    tuple val(sid), path("${sid}__t1_warped.nii.gz"), path("${sid}__output0GenericAffine.mat"), path("${sid}__output1Warp.nii.gz"), emit: t1_for_freesurfer_reg
    path("${sid}__output1InverseWarp.nii.gz")
    path("${sid}__t1_mask_warped.nii.gz")

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    export ANTS_RANDOM_SEED=1234
    antsRegistration --dimensionality 3 --float 0\
        --output [output,outputWarped.nii.gz,outputInverseWarped.nii.gz]\
        --interpolation Linear --use-histogram-matching 0\
        --winsorize-image-intensities [0.005,0.995]\
        --initial-moving-transform [$b0,$t1,1]\
        --transform Rigid['0.2']\
        --metric MI[$b0,$t1,1,32,Regular,0.25]\
        --convergence [500x250x125x50,1e-6,10] --shrink-factors 8x4x2x1\
        --smoothing-sigmas 3x2x1x0\
        --transform Affine['0.2']\
        --metric MI[$b0,$t1,1,32,Regular,0.25]\
        --convergence [500x250x125x50,1e-6,10] --shrink-factors 8x4x2x1\
        --smoothing-sigmas 3x2x1x0\
        --transform SyN[0.1,3,0]\
        --metric MI[$b0,$t1,1,32]\
        --metric CC[$fa,$t1,1,4]\
        --convergence [50x25x10,1e-6,10] --shrink-factors 4x2x1\
        --smoothing-sigmas 3x2x1
    mv outputWarped.nii.gz ${sid}__t1_warped.nii.gz
    mv output0GenericAffine.mat ${sid}__output0GenericAffine.mat
    mv output1InverseWarp.nii.gz ${sid}__output1InverseWarp.nii.gz
    mv output1Warp.nii.gz ${sid}__output1Warp.nii.gz
    antsApplyTransforms -d 3 -i $t1_mask -r ${sid}__t1_warped.nii.gz \
        -o ${sid}__t1_mask_warped.nii.gz -n NearestNeighbor \
        -t ${sid}__output1Warp.nii.gz ${sid}__output0GenericAffine.mat
    scil_image_math.py convert ${sid}__t1_mask_warped.nii.gz ${sid}__t1_mask_warped.nii.gz --data_type uint8 -f
    """
}