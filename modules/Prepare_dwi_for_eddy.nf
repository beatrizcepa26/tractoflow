process Prepare_dwi_for_eddy {

  cpus params.processes_cpus ?: params.process_prep_dwi_eddy

  input:
    tuple val(sid), file(dwi), file(bval), file(bvec), file(rev_dwi), file(rev_bval), \
        path(rev_bvec)

  output:
    path "${sid}_${task.process}_dstat.*"
    tuple val(sid), path("${sid}__concatenated_dwi.nii.gz"), path("${sid}__concatenated_dwi.bval"), path("${sid}__concatenated_dwi.bvec"), env ('rev_number_dir'), emit: concatenated_dwi_for_eddy

  script:
  """
    python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

    scil_concatenate_dwi.py ${sid}__concatenated_dwi.nii.gz ${sid}__concatenated_dwi.bval ${sid}__concatenated_dwi.bvec -f\
      --in_dwis ${dwi} ${rev_dwi} --in_bvals ${bval} ${rev_bval}\
      --in_bvecs ${bvec} ${rev_bvec}

    rev_number_dir=\$(scil_print_header.py ${rev_dwi} --key dim | sed "s/  / /g" | sed "s/  / /g" | rev | cut -d' ' -f4-4 | rev)
  """
}