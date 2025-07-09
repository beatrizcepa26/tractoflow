process PFT_Tracking {

    cpus params.process_pft_tracking

    input:
    tuple val(sid), path(fodf), path(incl), path(exclude), path(seed)   // include -> incl do to conflit
        //from fodf_maps_for_pft_tracking
    each curr_seed //from pft_random_seed

    output:
    path("${sid}__pft_tracking_${params.pft_algo}_${params.pft_seeding_mask_type}_seed_${curr_seed}.trk")

    //when:
      //  params.run_pft_tracking

    script:
    compress =\
        params.pft_compress_streamlines ? '--compress ' + params.pft_compress_value : ''
        """
        export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
        export OMP_NUM_THREADS=1
        export OPENBLAS_NUM_THREADS=1
        scil_compute_pft.py $fodf $seed $incl $exclude\
            tmp.trk\
            --algo $params.pft_algo --$params.pft_seeding $params.pft_nbr_seeds\
            --seed $curr_seed --step $params.pft_step --theta $params.pft_theta\
            --sfthres $params.pft_sfthres --sfthres_init $params.pft_sfthres_init\
            --min_length $params.pft_min_len --max_length $params.pft_max_len\
            --particles $params.pft_particles --back $params.pft_back\
            --forward $params.pft_front $compress --sh_basis $params.basis
        scil_remove_invalid_streamlines.py tmp.trk\
            ${sid}__pft_tracking_${params.pft_algo}_${params.pft_seeding_mask_type}_seed_${curr_seed}.trk\
            --remove_single_point
        """
}