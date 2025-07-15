process Local_Seeding_Mask {
    cpus params.processes_cpus ?: params.process_local_seed_mask

    input:
    tuple val(sid), path(wm), path(fa)

    output:
    tuple val(sid), path("${sid}__local_seeding_mask.nii.gz"), emit: tracking_seeding_mask_for_local

    script:
    if (params.local_seeding_mask_type == "wm")
        """
        mv $wm ${sid}__local_seeding_mask.nii.gz
        """
    else if (params.local_seeding_mask_type == "fa")
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        mrcalc $fa $params.local_fa_seeding_mask_threshold -ge ${sid}__local_seeding_mask.nii.gz -datatype uint8
        """
}