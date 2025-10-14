process Eddy {
    cpus { params.processes_eddy * task.attempt }
    memory { 5.GB * task.attempt }

    input:
    tuple val(sid), path(dwi), path(bval), path(bvec), path(mask), val(readout), val(encoding)

        //from dwi_gradients_mask_topup_files_for_eddy
    val(rev_b0_count) // from rev_b0_counter
    val(rev_dwi_count) // from rev_dwi_counter

    output:
    tuple val(sid), path("${sid}__dwi_corrected.nii.gz") 
        // into dwi_from_eddy
    tuple val(sid), path("${sid}__bval_eddy"), path("${sid}__dwi_eddy_corrected.bvec") 
        // into gradients_from_eddy

    //when:
    //(rev_b0_count == 0 && rev_dwi_count == 0 && params.run_eddy) || (!params.run_topup && params.run_eddy)

    // Corrected DWI is clipped to 0 since Eddy can introduce negative values.
    script:
        slice_drop_flag=""
        if (params.use_slice_drop_correction) {
            slice_drop_flag="--slice_drop_correction"
        }
        """
        export OMP_NUM_THREADS=$task.cpus
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
        export OPENBLAS_NUM_THREADS=1
        export MPLCONFIGDIR="/home/beatriz.cepa/.config"
        mkdir -p \$MPLCONFIGDIR
        scil_prepare_eddy_command.py $dwi $bval $bvec $mask\
            --eddy_cmd $params.eddy_cmd --b0_thr $params.b0_thr_extract_b0\
            --encoding_direction $encoding\
            --readout $readout --out_script --fix_seed\
            $slice_drop_flag
        sh eddy.sh
        fslmaths dwi_eddy_corrected.nii.gz -thr 0 ${sid}__dwi_corrected.nii.gz
        mv dwi_eddy_corrected.eddy_rotated_bvecs ${sid}__dwi_eddy_corrected.bvec
        mv $bval ${sid}__bval_eddy
        """
}