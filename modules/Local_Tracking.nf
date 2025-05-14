process Local_Tracking {
    cpus { params.processes_local_tracking * task.attempt }
    memory { 5.GB * task.attempt }

    input:
    tuple val(sid), path(fodf), path(tracking_mask), path(seed)\
        // from fodf_maps_for_local_tracking
    each curr_seed //from local_random_seed

    output:
    path("${sid}__local_tracking_${params.local_algo}_${params.local_seeding_mask_type}_seeding_${params.local_tracking_mask_type}_mask_seed_${curr_seed}.trk")

    //when:
    //    params.run_local_tracking

    script:
    compress =\
        params.local_compress_streamlines ? '--compress ' + params.local_compress_value : ''
    use_gpu =\
        params.local_tracking_gpu ? '--use_gpu --batch_size ' + params.local_batch_size_gpu : ''

        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_compute_local_tracking.py $fodf $seed $tracking_mask\
            tmp.trk\
            --algo $params.local_algo --$params.local_seeding $params.local_nbr_seeds\
            --seed $curr_seed --step $params.local_step --theta $params.local_theta\
            --sf $params.local_sfthres --min_length $params.local_min_len\
            --max_length $params.local_max_len $compress --sh_basis $params.basis\
            $use_gpu 

        scil_remove_invalid_streamlines.py tmp.trk\
            ${sid}__local_tracking_${params.local_algo}_${params.local_seeding_mask_type}_seeding_${params.local_tracking_mask_type}_mask_seed_${curr_seed}.trk\
            --remove_single_point
        """
}