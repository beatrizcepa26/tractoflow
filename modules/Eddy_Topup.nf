process Eddy_Topup {
    cpus { params.processes_eddy * task.attempt }
    memory { 5.GB * task.attempt }

    input:
    tuple value(sid), path(dwi), path(bval), path(bvec), val(number_rev_dwi), path(b0s_corrected),
        path(field), path(movpar), readout, encoding\
        from dwi_gradients_mask_topup_files_for_eddy_topup
    val(rev_b0_count) from rev_b0_counter
    val(rev_dwi_count) from rev_dwi_counter

    output:
    tuple value(sid), path("${sid}__dwi_corrected.nii.gz") into\
        dwi_from_eddy_topup
    tuple value(sid), path("${sid}__bval_eddy"), path("${sid}__dwi_eddy_corrected.bvec") into\
        gradients_from_eddy_topup
    path("${sid}__b0_bet_mask.nii.gz")

    when:
    (rev_b0_count > 0 || rev_dwi_count > 0) && params.run_topup && params.run_eddy

    // Corrected DWI is clipped to ensure there are no negative values
    // introduced by Eddy.
    script:
        slice_drop_flag=""
        if (params.use_slice_drop_correction)
            slice_drop_flag="--slice_drop_correction"
        """
        export OMP_NUM_THREADS=$task.cpus
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
        export OPENBLAS_NUM_THREADS=1
        mrconvert $b0s_corrected b0_corrected.nii.gz -coord 3 0 -axes 0,1,2 -nthreads 1
        bet b0_corrected.nii.gz ${sid}__b0_bet.nii.gz -m -R\
            -f $params.bet_topup_before_eddy_f
        scil_prepare_eddy_command.py $dwi $bval $bvec ${sid}__b0_bet_mask.nii.gz\
            --topup $params.prefix_topup --eddy_cmd $params.eddy_cmd\
            --b0_thr $params.b0_thr_extract_b0\
            --encoding_direction $encoding\
            --readout $readout --out_script --fix_seed\
            --n_reverse ${number_rev_dwi}\
            --lsr_resampling\
            $slice_drop_flag
	echo "--very_verbose" >> eddy.sh
	sh eddy.sh
        fslmaths dwi_eddy_corrected.nii.gz -thr 0 ${sid}__dwi_corrected.nii.gz

	if [[ $number_rev_dwi -eq 0 ]]
	then
	   mv dwi_eddy_corrected.eddy_rotated_bvecs ${sid}__dwi_eddy_corrected.bvec
          mv $bval ${sid}__bval_eddy
	else
	   scil_validate_and_correct_eddy_gradients.py dwi_eddy_corrected.eddy_rotated_bvecs $bval ${number_rev_dwi} ${sid}__dwi_eddy_corrected.bvec ${sid}__bval_eddy
	fi
	"""
}