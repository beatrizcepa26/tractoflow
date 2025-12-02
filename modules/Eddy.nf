process Eddy {
    // memory { 5.GB * task.attempt }
    label 'gpu_capable'

    when:
    (!params.run_topup && params.run_eddy)

    input:
    tuple val(sid), path(dwi), path(bval), path(bvec), path(mask), val(readout), val(encoding)
    val(rev_b0_count)
    val(rev_dwi_count)

    output:
    tuple val(sid), path("${sid}__dwi_corrected.nii.gz"), emit : dwi_from_eddy
    tuple val(sid), path("${sid}__bval_eddy"), path("${sid}__dwi_eddy_corrected.bvec"), emit: gradients_from_eddy

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
        scil_prepare_eddy_command.py $dwi $bval $bvec $mask\
            --eddy_cmd $params.eddy_cmd --b0_thr $params.b0_thr_extract_b0\
            --encoding_direction $encoding\
            --readout $readout --out_script --fix_seed\
            $slice_drop_flag
        sed -i "s|\beddy_cuda\b|/fsl/opt/fsl-6.0.7.8/bin/eddy_cuda|g" eddy.sh
        sh eddy.sh
        fslmaths dwi_eddy_corrected.nii.gz -thr 0 ${sid}__dwi_corrected.nii.gz
        mv dwi_eddy_corrected.eddy_rotated_bvecs ${sid}__dwi_eddy_corrected.bvec
        mv $bval ${sid}__bval_eddy
        """
}
