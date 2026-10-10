def pft_trackers(cpus) {
    def fit = params.max_memory_gb ? (params.max_memory_gb as int).intdiv(params.pft_tracker_memory_gb as int) : cpus
    return Math.max(1, [cpus as int, params.pft_max_trackers as int, fit as int].min())
}

process PFT_Tracking {

    cpus params.processes_cpus ?: params.process_pft_tracking
    memory { "${pft_trackers(task.cpus) * (params.pft_tracker_memory_gb as int)} GB" }

    input:
    tuple val(sid), path(fodf), path(incl), path(exclude), path(seed)   // include -> incl do to conflit
    each curr_seed

    output:
    path "${sid}_${task.process}_dstat.*"
    path("${sid}__pft_tracking_${params.pft_algo}_${params.pft_seeding_mask_type}_seed_${curr_seed}.trk")

    script:
    compress =\
        params.pft_compress_streamlines ? '--compress ' + params.pft_compress_value : ''
    trackers = pft_trackers(task.cpus)
    out = "${sid}__pft_tracking_${params.pft_algo}_${params.pft_seeding_mask_type}_seed_${curr_seed}.trk"
        """
        python /dstat.py -tcdrnmg -C all --float --noheaders --output ${sid}_${task.process}_dstat.csv > ${sid}_${task.process}_dstat.csv 2>&1 &

        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        split_seed_mask.py $seed $trackers part
        pids=""
        for mask in part_*.nii.gz; do
            scil_compute_pft.py $fodf \$mask $incl $exclude\
                \${mask%.nii.gz}_raw.trk\
                --algo $params.pft_algo --$params.pft_seeding $params.pft_nbr_seeds\
                --seed $curr_seed --step $params.pft_step --theta $params.pft_theta\
                --sfthres $params.pft_sfthres --sfthres_init $params.pft_sfthres_init\
                --min_length $params.pft_min_len --max_length $params.pft_max_len\
                --particles $params.pft_particles --back $params.pft_back\
                --forward $params.pft_front $compress --sh_basis $params.basis &
            pids="\$pids \$!"
        done
        for pid in \$pids; do wait \$pid; done
        for raw in part_*_raw.trk; do
            scil_remove_invalid_streamlines.py \$raw \${raw%_raw.trk}.trk --remove_single_point
        done
        join_trk.py $out part_[0-9]*[0-9].trk
        """
}