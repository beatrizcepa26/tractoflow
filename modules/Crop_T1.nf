process Crop_T1 {
    cpus params.processes_cpus ?: params.process_crop_t1

    input:
    tuple val(sid), path(t1), path(t1_mask)

    output:
    path "${sid}_${task.process}_dstat.*"
    tuple val(sid), path("*__t1_bet_cropped.nii.gz"), path("*__t1_bet_mask_cropped.nii.gz"), emit: t1_and_mask_for_reg

    script:
    """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

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