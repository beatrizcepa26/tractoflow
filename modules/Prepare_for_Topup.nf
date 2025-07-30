process Prepare_for_Topup {

  input:
    tuple val(sid), val(rev), file(dwi), file(bval), path(bvec) 

  output:
    tuple val(sid), path("${sid}_${rev}b0_mean.nii.gz"), val(rev), emit: simple_b0_for_topup

  script:
  """
    scil_extract_b0.py $dwi $bval $bvec ${sid}_${rev}b0_mean.nii.gz --mean\
        --b0_thr $params.b0_thr_extract_b0 --force_b0_threshold
  """
}