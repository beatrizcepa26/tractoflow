process Prepare_for_Topup {
  cpus 2

  input:
    set sid, val(rev), file(dwi), file(bval), file(bvec)\
      from dwi_gradients_rev_b0_for_prepare_topup

  output:
    set sid, "${sid}_${rev}b0_mean.nii.gz", val(rev) into simple_b0_for_topup

  when:
    params.run_topup && params.run_eddy

  script:
  """
    scil_extract_b0.py $dwi $bval $bvec ${sid}_${rev}b0_mean.nii.gz --mean\
        --b0_thr $params.b0_thr_extract_b0 --force_b0_threshold
  """
}