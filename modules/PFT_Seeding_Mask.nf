process PFT_Seeding_Mask {

    cpus params.processes_cpus ?: params.process_pft_seeding_mask

    input:
    tuple val(sid), path(wm), path(fa), path(interface_mask)

    output:
    path "${sid}_${task.process}_dstat.*"
    tuple val(sid), path("${sid}__pft_seeding_mask.nii.gz"), emit: seeding_mask_for_pft

    script:
    if (params.pft_seeding_mask_type == "wm")
        """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_image_math.py union $wm $interface_mask ${sid}__pft_seeding_mask.nii.gz\
            --data_type uint8
        """
    else if (params.pft_seeding_mask_type == "interface")
        """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

        mv $interface_mask ${sid}__pft_seeding_mask.nii.gz
        """
    else if (params.pft_seeding_mask_type == "fa")
        """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        mrcalc $fa $params.pft_fa_seeding_mask_threshold -ge ${sid}__pft_seeding_mask.nii.gz\
          -datatype uint8
        """
}