process Local_Tracking_Mask {
    cpus 1

    input:
    tuple value(sid), path(wm), path(fa) from wm_fa_for_local_tracking_mask

    output:
    tuple value(sid), path("${sid}__local_tracking_mask.nii.gz") into tracking_mask_for_local

    when:
        params.run_local_tracking

    script:
    if (params.local_tracking_mask_type == "wm")
        """
        mv $wm ${sid}__local_tracking_mask.nii.gz
        """
    else if (params.local_tracking_mask_type == "fa")
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        mrcalc $fa $params.local_fa_tracking_mask_threshold -ge ${sid}__local_tracking_mask.nii.gz\
          -datatype uint8
        """
}