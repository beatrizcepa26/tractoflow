process Prepare_for_Topup {

  cpus params.processes_cpus ?: params.process_prep_topup

  input:
    tuple val(sid), val(rev), file(dwi), file(bval), path(bvec) 

  output:
    path "${sid}_${task.process}_dstat.*"
    tuple val(sid), path("${sid}_${rev}b0_mean.nii.gz"), val(rev), emit: simple_b0_for_topup

  script:
  """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

    scil_extract_b0.py $dwi $bval $bvec ${sid}_${rev}b0_mean.nii.gz --mean\
        --b0_thr $params.b0_thr_extract_b0 --force_b0_threshold
  """
}