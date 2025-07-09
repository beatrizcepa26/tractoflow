process Segment_Tissues {
    cpus params.process_segment_tissues

    input:
    tuple val(sid), path(t1) // from t1_for_seg

    output:
    tuple val(sid), path("${sid}__map_wm.nii.gz"), path("${sid}__map_gm.nii.gz"), \
        path("${sid}__map_csf.nii.gz"), emit: map_wm_gm_csf_for_pft_maps
    tuple val(sid), path("${sid}__mask_wm.nii.gz"), emit: wm_mask_for_pft_tracking //, wm_mask_fast
    path("${sid}__mask_gm.nii.gz")
    path("${sid}__mask_csf.nii.gz")

    //when:
        //!params.run_tractoflow_abs

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    fast -t 1 -n $params.number_of_tissues\
         -H 0.1 -I 4 -l 20.0 -g -o t1.nii.gz $t1
    scil_image_math.py convert t1_seg_2.nii.gz ${sid}__mask_wm.nii.gz --data_type uint8
    scil_image_math.py convert t1_seg_1.nii.gz ${sid}__mask_gm.nii.gz --data_type uint8
    scil_image_math.py convert t1_seg_0.nii.gz ${sid}__mask_csf.nii.gz --data_type uint8
    mv t1_pve_2.nii.gz ${sid}__map_wm.nii.gz
    mv t1_pve_1.nii.gz ${sid}__map_gm.nii.gz
    mv t1_pve_0.nii.gz ${sid}__map_csf.nii.gz
    """
}