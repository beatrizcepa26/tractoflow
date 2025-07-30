process PFT_Tracking_Maps {

    input:
    tuple val(sid), path(wm), path(gm), path(csf)

    output:
    tuple val(sid), path("${sid}__map_include.nii.gz"),
        path("${sid}__map_exclude.nii.gz"), emit: pft_maps_for_pft_tracking
    tuple val(sid), path("${sid}__interface.nii.gz"), emit: interface_for_pft_seeding_mask

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