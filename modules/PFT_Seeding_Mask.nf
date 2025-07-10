process PFT_Seeding_Mask {


    input:
    tuple val(sid), path(wm), path(fa), path(interface_mask) // from wm_fa_int_for_pft

    output:
    tuple val(sid), path("${sid}__pft_seeding_mask.nii.gz") // into seeding_mask_for_pft

    //when:
      //  params.run_pft_tracking

    script:
    if (params.pft_seeding_mask_type == "wm")
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_volume_math.py union $wm $interface_mask ${sid}__pft_seeding_mask.nii.gz\
            --data_type uint8
        """
    else if (params.pft_seeding_mask_type == "interface")
        """
        mv $interface_mask ${sid}__pft_seeding_mask.nii.gz
        """
    else if (params.pft_seeding_mask_type == "fa")
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        mrcalc $fa $params.pft_fa_seeding_mask_threshold -ge ${sid}__pft_seeding_mask.nii.gz\
          -datatype uint8
        """
}