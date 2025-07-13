process Segment_Freesurfer {
    cpus params.processes_cpus ?: params.process_segment_freesurfer

    input:
    tuple val(sid), path(aparc), path(wmparc) //from labels_for_segmentation

    output:
    tuple val(sid), path("${sid}__mask_wm.nii.gz"), emit: wm_mask_freesurfer
    path("${sid}__mask_gm.nii.gz")
    path("${sid}__mask_csf.nii.gz")

    //when:
        //params.run_tractoflow_abs

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    mkdir wmparc_desikan/
    mkdir wmparc_subcortical/
    mkdir aparc+aseg_subcortical/
    scil_image_math.py convert $aparc aparc+aseg_int16.nii.gz --data_type int16 -f
    scil_image_math.py convert $wmparc wmparc_int16.nii.gz --data_type int16 -f

    scil_split_volume_by_labels.py wmparc_int16.nii.gz --scilpy_lut freesurfer_desikan_killiany --out_dir wmparc_desikan
    scil_split_volume_by_labels.py wmparc_int16.nii.gz --scilpy_lut freesurfer_subcortical --out_dir wmparc_subcortical
    scil_split_volume_by_labels.py aparc+aseg_int16.nii.gz --scilpy_lut freesurfer_subcortical --out_dir aparc+aseg_subcortical

    scil_image_math.py union wmparc_desikan/*\
                             wmparc_subcortical/right-cerebellum-cortex.nii.gz\
                             wmparc_subcortical/left-cerebellum-cortex.nii.gz\
                             mask_cortex_m.nii.gz -f
    scil_image_math.py union wmparc_subcortical/corpus-callosum-*\
                             aparc+aseg_subcortical/*white-matter*\
                             wmparc_subcortical/brain-stem.nii.gz\
                             aparc+aseg_subcortical/*ventraldc*\
                             mask_wm_m.nii.gz -f
    scil_image_math.py union wmparc_subcortical/*thalamus*\
                             wmparc_subcortical/*putamen*\
                             wmparc_subcortical/*pallidum*\
                             wmparc_subcortical/*hippocampus*\
                             wmparc_subcortical/*caudate*\
                             wmparc_subcortical/*amygdala*\
                             wmparc_subcortical/*accumbens*\
                             wmparc_subcortical/*plexus*\
                             mask_nuclei_m.nii.gz -f
    scil_image_math.py union wmparc_subcortical/*-lateral-ventricle.nii.gz\
                             wmparc_subcortical/*-inferior-lateral-ventricle.nii.gz\
                             wmparc_subcortical/cerebrospinal-fluid.nii.gz\
                             wmparc_subcortical/*th-ventricle.nii.gz\
                             mask_csf_1_m.nii.gz -f
    scil_image_math.py lower_threshold mask_wm_m.nii.gz 0.1\
                                          ${sid}__mask_wm_bin.nii.gz -f
    scil_image_math.py lower_threshold mask_cortex_m.nii.gz 0.1\
                                          ${sid}__mask_gm.nii.gz -f
    scil_image_math.py lower_threshold mask_nuclei_m.nii.gz 0.1\
                                          ${sid}__mask_nuclei_bin.nii.gz -f
    scil_image_math.py lower_threshold mask_csf_1_m.nii.gz 0.1\
                                          ${sid}__mask_csf.nii.gz -f
    scil_image_math.py addition ${sid}__mask_wm_bin.nii.gz\
                                ${sid}__mask_nuclei_bin.nii.gz\
                                ${sid}__mask_wm.nii.gz --data_type int16

    scil_image_math.py convert ${sid}__mask_wm.nii.gz ${sid}__mask_wm.nii.gz --data_type uint8 -f
    scil_image_math.py convert ${sid}__mask_gm.nii.gz ${sid}__mask_gm.nii.gz --data_type uint8 -f
    scil_image_math.py convert ${sid}__mask_csf.nii.gz ${sid}__mask_csf.nii.gz --data_type uint8 -f
    """
}