process FODF_Metrics {
    label 'big_mem'

    input:
    tuple val(sid), path(dwi), path(bval), path(bvec), path(b0_mask), path(fa),
        path(md), path(frf)

    output:
    tuple val(sid), path("${sid}__fodf.nii.gz"), emit: fodf
    path("${sid}__peaks.nii.gz")
    path("${sid}__peak_indices.nii.gz")
    path("${sid}__afd_max.nii.gz")
    path("${sid}__afd_total.nii.gz")
    path("${sid}__afd_sum.nii.gz")
    path("${sid}__nufo.nii.gz")

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_compute_ssst_fodf.py $dwi $bval $bvec $frf ${sid}__fodf.nii.gz\
        --sh_order $params.sh_order --sh_basis $params.basis --force_b0_threshold\
        --mask $b0_mask --processes $task.cpus

    scil_compute_fodf_max_in_ventricles.py ${sid}__fodf.nii.gz $fa $md\
        --max_value_output ventricles_fodf_max_value.txt --sh_basis $params.basis\
        --fa_t $params.max_fa_in_ventricle --md_t $params.min_md_in_ventricle\
        -f

    v_max=\$(sed -E 's/([+-]?[0-9.]+)[eE]\\+?(-?)([0-9]+)/(\\1*10^\\2\\3)/g' <<<"\$(cat ventricles_fodf_max_value.txt)")
    a_threshold=\$(echo "scale=10; $params.fodf_metrics_a_factor*\$v_max" | bc)
    if (( \$(echo "\$a_threshold < 0" | bc -l) )); then
        a_threshold=0
    fi

    scil_compute_fodf_metrics.py ${sid}__fodf.nii.gz\
        --mask $b0_mask --sh_basis $params.basis\
        --peaks ${sid}__peaks.nii.gz --peak_indices ${sid}__peak_indices.nii.gz\
        --afd_max ${sid}__afd_max.nii.gz --afd_total ${sid}__afd_total.nii.gz\
        --afd_sum ${sid}__afd_sum.nii.gz --nufo ${sid}__nufo.nii.gz\
        --rt $params.relative_threshold --at \${a_threshold}
    """
}