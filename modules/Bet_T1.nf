process Bet_T1 {
    cpus params.processes ?:  params.processes_brain_extraction_t1

    input:
    tuple val(sid), path(t1) // from t1_for_bet

    output:
    tuple val(sid), path("*__t1_bet.nii.gz"), path("*__t1_bet_mask.nii.gz") 
        // into t1_and_mask_for_crop

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    export ANTS_RANDOM_SEED=1234
    antsBrainExtraction.sh -d 3 -a $t1 -e $params.template_t1/t1_template.nii.gz\
        -o bet/ -m $params.template_t1/t1_brain_probability_map.nii.gz -u 0
    scil_image_math.py convert bet/BrainExtractionMask.nii.gz ${sid}__t1_bet_mask.nii.gz --data_type uint8
    mrcalc $t1 ${sid}__t1_bet_mask.nii.gz -mult ${sid}__t1_bet.nii.gz -nthreads 1
    """
}