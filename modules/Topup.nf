process Topup {
    cpus 4

    input:
      tuple val(sid), file(rev_b0), file(b0),  val(readout), val(encoding) // from rev_b0_with_readout_encoding_for_topup

    output:
      tuple val(sid), path("${sid}__corrected_b0s.nii.gz"), path("${params.prefix_topup}_fieldcoef.nii.gz"),
      path("${params.prefix_topup}_movpar.txt") //into topup_files_for_eddy_topup
      file "${sid}__rev_b0_warped.nii.gz"
      file "${sid}__rev_b0_mean.nii.gz"

    when:
      params.run_topup && params.run_eddy

    script:
    """
      export OMP_NUM_THREADS=$task.cpus
      export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
      export OPENBLAS_NUM_THREADS=1
      export ANTS_RANDOM_SEED=1234
      git 

      scil_image_math.py convert $rev_b0 $rev_b0 -f --data_type float32
      scil_image_math.py convert $b0 $b0 -f --data_type float32
      scil_image_math.py concatenate $rev_b0 $rev_b0 ${sid}__concatenated_rev_b0.nii.gz
      scil_image_math.py mean ${sid}__concatenated_rev_b0.nii.gz ${sid}__rev_b0_mean.nii.gz
      antsRegistrationSyNQuick.sh -d 3 -f $b0 -m ${sid}__rev_b0_mean.nii.gz -o output -t r -e 1
      mv outputWarped.nii.gz ${sid}__rev_b0_warped.nii.gz
      scil_prepare_topup_command.py $b0 ${sid}__rev_b0_warped.nii.gz\
          --config $params.config_topup\
          --encoding_direction $encoding\
          --readout $readout --out_prefix $params.prefix_topup\
          --out_script
      sh topup.sh
      cp corrected_b0s.nii.gz ${sid}__corrected_b0s.nii.gz
    """
}