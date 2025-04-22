process PFT_Tracking_Maps {
    cpus 1

    input:
    set sid, file(wm), file(gm), file(csf) from map_wm_gm_csf_for_pft_maps

    output:
    set sid, "${sid}__map_include.nii.gz",
        "${sid}__map_exclude.nii.gz" into pft_maps_for_pft_tracking
    set sid, "${sid}__interface.nii.gz" into interface_for_pft_seeding_mask

    when:
        params.run_pft_tracking

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_compute_maps_for_particle_filter_tracking.py $wm $gm $csf \
        --include ${sid}__map_include.nii.gz \
        --exclude ${sid}__map_exclude.nii.gz \
        --interface ${sid}__interface.nii.gz -f
    """
}