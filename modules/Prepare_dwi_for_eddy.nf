process Prepare_dwi_for_eddy {
  cpus 2

  input:
    set sid, file(dwi), file(bval), file(bvec), file(rev_dwi), file(rev_bval), \
        file(rev_bvec) from dwi_rev_gradient_for_prepare_dwi_for_eddy

  output:
    set sid, "${sid}__concatenated_dwi.nii.gz", "${sid}__concatenated_dwi.bval", "${sid}__concatenated_dwi.bvec", env(rev_number_dir) into concatenated_dwi_for_eddy

  when:
    params.run_topup && params.run_eddy

  script:
  """
    scil_concatenate_dwi.py ${sid}__concatenated_dwi.nii.gz ${sid}__concatenated_dwi.bval ${sid}__concatenated_dwi.bvec -f\
      --in_dwis ${dwi} ${rev_dwi} --in_bvals ${bval} ${rev_bval}\
      --in_bvecs ${bvec} ${rev_bvec}

    rev_number_dir=\$(scil_print_header.py ${rev_dwi} --key dim | sed "s/  / /g" | sed "s/  / /g" | rev | cut -d' ' -f4-4 | rev)
  """
}