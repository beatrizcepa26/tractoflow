process Mean_FRF {
    cpus 1
    publishDir params.Mean_FRF_Publish_Dir
    tag "All_FRF"

    input:
    path(all_frf) // from all_frf_for_mean_frf

    output:
    path("mean_frf.txt") // into mean_frf

    //when:
    //params.mean_frf && !params.set_frf

    script:
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_compute_mean_frf.py $all_frf mean_frf.txt
    """
}