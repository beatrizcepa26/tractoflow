#!/usr/bin/env nextflow

include {README} from "./modules/README.nf"
include {Read_BIDS} from "./modules/Read_BIDS.nf"
include {Bet_Prelim_DWI} from "./modules/Bet_Prelim_DWI.nf"
include {Denoise_DWI} from "./modules/Denoise_DWI.nf"
include {Gibbs_correction} from "./modules/Gibbs_correction.nf"
include {Prepare_for_Topup} from "./modules/Prepare_for_Topup.nf"
include {Topup} from "./modules/Topup.nf"
include {Prepare_dwi_for_eddy} from "./modules/Prepare_dwi_for_eddy.nf"
include {Eddy_Topup} from "./modules/Eddy_Topup.nf"
include {Eddy} from "./modules/Eddy.nf"
include {Bet_DWI} from "./modules/Bet_DWI.nf"
include {N4_DWI} from "./modules/N4_DWI.nf"
include {Crop_DWI} from "./modules/Crop_DWI.nf"
include { Denoise_T1 } from "./modules/Denoise_T1.nf"
include { N4_T1 } from "./modules/N4_T1.nf"
include { Resample_T1 } from "./modules/Resample_T1.nf"
include { Bet_T1 } from "./modules/Bet_T1.nf"
include { Crop_T1 } from "./modules/Crop_T1.nf"
include { Normalize_DWI } from "./modules/Normalize_DWI.nf"
include { Resample_DWI } from "./modules/Resample_DWI.nf"
include { Extract_B0 } from "./modules/Extract_B0.nf"
include { Extract_SH_Fitting_Shell } from "./modules/Extract_SH_Fitting_Shell.nf"
include { SH_Fitting } from "./modules/SH_Fitting.nf"
include { Extract_DTI_Shell } from "./modules/Extract_DTI_Shell.nf"
include { DTI_Metrics } from "./modules/DTI_Metrics.nf"
include { Extract_FODF_Shell } from "./modules/Extract_FODF_Shell.nf"


import groovy.json.*

// ---------------- Workflows of processes -------------------



workflow gibbs_correction {
    include {Gibbs_correction} from "./modules/Gibbs_correction.nf"
    dwi_gibbs_for_mix = Gibbs_correction(dwi_for_gibbs: dwi_for_gibbs)
}


workflow prepare_for_topup {
    include { Prepare_for_Topup } from "./modules/Prepare_for_Topup.nf"
    simple_b0_for_topup = Prepare_for_Topup(dwi_gradients_rev_b0_for_prepare_topup: dwi_gradients_rev_b0_for_prepare_topup)
}


workflow topup {
    include { Topup } from "./modules/Topup.nf"
    topup_files_for_eddy_topup = Topup(rev_b0_with_readout_encoding_for_topup: rev_b0_with_readout_encoding_for_topup)
}


workflow prepare_dwi_for_eddy {
    include { Prepare_dwi_for_eddy } from "./modules/Prepare_dwi_for_eddy.nf"
    concatenated_dwi_for_eddy = Prepare_dwi_for_eddy(dwi_rev_gradient_for_prepare_dwi_for_eddy: dwi_rev_gradient_for_prepare_dwi_for_eddy)
}


workflow eddy_topup {
    include { Eddy_Topup } from "./modules/Eddy_Topup.nf"
    // eddy_topup_results = Eddy_Topup(dwi_gradients_mask_topup_files_for_eddy_topup: dwi_gradients_mask_topup_files_for_eddy_topup,
    // rev_b0_count: rev_b0_counter,
    // rev_dwi_count: rev_dwi_counter,)
}


workflow eddy{
    include { Eddy } from "./modules/Eddy.nf"
    // dwi_from_eddy_topup = Eddy(dwi_gradients_mask_topup_files_for_eddy: dwi_gradients_mask_topup_files_for_eddy,
    //     rev_b0_count: rev_b0_counter,
    //     rev_dwi_count: rev_dwi_counter)
}


workflow bet_dwi {
    include { Bet_DWI } from "./modules/Bet_DWI.nf"
    // b0_and_mask_for_crop = Bet_DWI(dwi_gradients_for_bet: dwi_gradients_for_bet)
}


workflow n4_dwi {
    include { N4_DWI } from "./modules/N4_DWI.nf"
    dwi_for_crop = N4_DWI(dwi_b0_b0_mask_for_n4: dwi_b0_b0_mask_for_n4)
}


workflow crop_dwi {
    include { Crop_DWI } from "./modules/Crop_DWI.nf"
    // dwi_mask_for_normalize = Crop_DWI(dwi_and_b0_mask_b0_for_crop: dwi_and_b0_mask_b0_for_crop)
}


workflow denoise_t1 {
    include { Denoise_T1 } from "./modules/Denoise_T1.nf"
    t1_for_mix_n4 = Denoise_T1(t1_for_denoise: t1_for_denoise)
}


workflow n4_t1 {
    include { N4_T1 } from "./modules/N4_T1.nf"
    // t1_for_bet = N4_T1(t1_for_n4: t1_for_n4)
}


workflow resample_t1 {
    include { Resample_T1 } from "./modules/Resample_T1.nf"
    // t1_resampled_for_mix = Resample_T1(t1_for_bet: t1_for_bet)
}


workflow bet_t1 {
    include { Bet_T1 } from "./modules/Bet_T1.nf"
    // t1_and_mask_for_crop = Bet_T1(t1_for_bet: t1_for_bet)
}


workflow crop_t1 {
    include { Crop_T1 } from "./modules/Crop_T1.nf"
    // t1_and_mask_for_reg = Crop_T1(t1_and_mask_for_crop: t1_and_mask_for_crop)
}


workflow normalize_dwi{
    include { Normalize_DWI } from "./modules/Normalize_DWI.nf"
    // dwi_for_resample = Normalize_DWI(dwi_mask_for_normalize: dwi_mask_for_normalize)
}


workflow resample_dwi {
    include { Resample_DWI } from "./modules/Resample_DWI.nf"
    // dwi_for_mix = Resample_DWI(dwi_mask_for_resample: dwi_mask_for_resample)
}


workflow extract_b0 {
    include { Extract_B0 } from "./modules/Extract_B0.nf"
    // b0_for_reg = Extract_B0(dwi_and_grad_for_extract_b0: dwi_and_grad_for_extract_b0)
}


workflow extract_sh_fitting_shell{
    include { Extract_SH_Fitting_Shell } from "./modules/Extract_SH_Fitting_Shell.nf"
    // dwi_and_grad_for_sh_fitting = Extract_SH_Fitting_Shell(dwi_and_grad_for_extract_sh_fitting_shell: dwi_and_grad_for_extract_sh_fitting_shell)
}


workflow sh_fitting_workflow {
    include { SH_Fitting } from "./modules/SH_Fitting.nf"
    // SH_Fitting(dwi_and_grad_for_sh_fitting: dwi_and_grad_for_sh_fitting)
}


workflow extract_dti_shell{
    include { Extract_DTI_Shell } from "./modules/Extract_DTI_Shell.nf"
    // dwi_and_grad_for_dti_metrics = Extract_DTI_Shell(dwi_and_grad_for_extract_dti_shell: dwi_and_grad_for_extract_dti_shell)
}


workflow dti_metrics{
    include { DTI_Metrics } from "./modules/DTI_Metrics.nf"
    // DTI_Metrics(dwi_and_grad_for_dti_metrics: dwi_and_grad_for_dti_metrics)
}


workflow extract_fodf_shell{
    include { FODF_Metrics } from "./modules/FODF_Metrics.nf"
    // FODF_Metrics(dwi_and_grad_for_fodf_metrics: dwi_and_grad_for_fodf_metrics)
}


workflow register_t1{
    include { Register_T1 } from "./modules/Register_T1.nf"
    // Register_T1(t1_and_mask_for_reg: t1_and_mask_for_reg)
}


workflow register_freesurfer{
    include { Register_Freesurfer } from "./modules/Register_Freesurfer.nf"
    // labels_for_segmentation = Register_Freesurfer(labels_mat_for_reg: labels_mat_for_reg)
}


workflow segment_freesurfer{
    include { Segment_Freesurfer } from "./modules/Segment_Freesurfer.nf"
    // wm_mask_freesurfer = Segment_Freesurfer(labels_for_segmentation: labels_for_segmentation)
}


workflow segment_tissues{
    include { Segment_Tissues } from "./modules/Segment_Tissues.nf"
    // Segment_Tissues(t1_for_seg: t1_for_seg)
}


workflow compute_frf{
    include { Compute_FRF } from "./modules/Compute_FRF.nf"
    // Compute_FRF(dwi_b0_for_rf: dwi_b0_for_rf)
}


workflow mean_frf_workflow{
    include { Mean_FRF } from "./modules/Mean_FRF.nf"
    // mean_frf = Mean_FRF(all_frf_for_mean_frf: all_frf_for_mean_frf)
}


workflow fodf_metrics{
    include { FODF_Metrics } from "./modules/FODF_Metrics.nf"
    // FODF_Metrics(dwi_b0_metrics_frf_for_fodf: dwi_b0_metrics_frf_for_fodf)
}


workflow pft_tracking_maps{
    include { PFT_Tracking_Maps } from "./modules/PFT_Tracking_Maps.nf"
    // PFT_Tracking_Maps(map_wm_gm_csf_for_pft_maps: map_wm_gm_csf_for_pft_maps)
}


workflow pft_seeding_mask{
    include { PFT_Seeding_Mask } from "./modules/PFT_Seeding_Mask.nf"
    // seeding_mask_for_pft = PFT_Seeding_Mask(wm_fa_int_for_pft: wm_fa_int_for_pft)
}


workflow pft_tracking{
    include { PFT_Tracking } from "./modules/PFT_Tracking.nf"
    // PFT_Tracking(fodf_maps_for_pft_tracking: fodf_maps_for_pft_tracking,
    //     pft_random_seed: pft_random_seed)
}


workflow local_tracking_mask{
    include { Local_Tracking_Mask } from "./modules/Local_Tracking_Mask.nf"
    // tracking_mask_for_local = Local_Tracking_Mask(wm_fa_for_local_tracking_mask: wm_fa_for_local_tracking_mask)
}


workflow local_seeding_mask{
    include { Local_Seeding_Mask } from "./modules/Local_Seeding_Mask.nf"
    // tracking_seeding_mask_for_local = Local_Seeding_Mask(wm_fa_for_local_seeding_mask: wm_fa_for_local_seeding_mask)
}


workflow local_tracking{
    include { Local_Tracking } from "./modules/Local_Tracking.nf"
    // Local_Tracking(fodf_maps_for_local_tracking: fodf_maps_for_local_tracking,
    //     local_random_seed: local_random_seed)
}


// ---------------- Main workflow -------------------



params.input = false
params.fs = false
params.bidsignore = false
params.bids = false
params.bids_config = false
params.help = false
params.dti_shells = false
params.fodf_shells = false

if(params.help) {
    usage = file("$baseDir/USAGE")

    cpu_count = Runtime.runtime.availableProcessors()
    bindings = ["clean_bids":"$params.clean_bids",
                "sh_fitting":"$params.sh_fitting",
                "sh_fitting_basis":"$params.sh_fitting_basis",
                "sh_fitting_order":"$params.sh_fitting_order",
                "b0_thr_extract_b0":"$params.b0_thr_extract_b0",
                "dwi_shell_tolerance":"$params.dwi_shell_tolerance",
                "dilate_b0_mask_prelim_brain_extraction":"$params.dilate_b0_mask_prelim_brain_extraction",
                "bet_prelim_f":"$params.bet_prelim_f",
                "run_dwi_denoising":"$params.run_dwi_denoising",
                "extent":"$params.extent",
                "run_gibbs_correction": "$params.run_gibbs_correction",
                "run_topup":"$params.run_topup",
                "encoding_direction":"$params.encoding_direction",
                "readout":"$params.readout",
                "run_eddy":"$params.run_eddy",
                "eddy_cmd":"$params.eddy_cmd",
                "bet_topup_before_eddy_f":"$params.bet_topup_before_eddy_f",
                "use_slice_drop_correction":"$params.use_slice_drop_correction",
                "bet_dwi_final_f":"$params.bet_dwi_final_f",
                "fa_mask_threshold":"$params.fa_mask_threshold",
                "run_resample_dwi":"$params.run_resample_dwi",
                "dwi_resolution":"$params.dwi_resolution",
                "dwi_interpolation":"$params.dwi_interpolation",
                "max_dti_shell_value":"$params.max_dti_shell_value",
                "min_fodf_shell_value":"$params.min_fodf_shell_value",
                "run_t1_denoising":"$params.run_t1_denoising",
                "run_resample_t1":"$params.run_resample_t1",
                "t1_resolution":"$params.t1_resolution",
                "t1_interpolation":"$params.t1_interpolation",
                "number_of_tissues":"$params.number_of_tissues",
                "fa":"$params.fa",
                "min_fa":"$params.min_fa",
                "min_nvox":"$params.min_nvox",
                "roi_radius":"$params.roi_radius",
                "set_frf":"$params.set_frf",
                "manual_frf":"$params.manual_frf",
                "mean_frf":"$params.mean_frf",
                "sh_order":"$params.sh_order",
                "basis":"$params.basis",
                "fodf_metrics_a_factor":"$params.fodf_metrics_a_factor",
                "relative_threshold":"$params.relative_threshold",
                "max_fa_in_ventricle":"$params.max_fa_in_ventricle",
                "min_md_in_ventricle":"$params.min_md_in_ventricle",
                "run_pft_tracking":"$params.run_pft_tracking",
                "pft_seeding_mask_type":"$params.pft_seeding_mask_type",
                "pft_fa_seeding_mask_threshold":"$params.pft_fa_seeding_mask_threshold",
                "pft_algo":"$params.pft_algo",
                "pft_seeding":"$params.pft_seeding",
                "pft_nbr_seeds":"$params.pft_nbr_seeds",
                "pft_step":"$params.pft_step",
                "pft_theta":"$params.pft_theta",
                "pft_min_len":"$params.pft_min_len",
                "pft_max_len":"$params.pft_max_len",
                "pft_compress_streamlines":"$params.pft_compress_streamlines",
                "pft_compress_value":"$params.pft_compress_value",
                "local_seeding_mask_type":"$params.local_seeding_mask_type",
                "local_fa_seeding_mask_threshold":"$params.local_fa_seeding_mask_threshold",
                "local_tracking_mask_type":"$params.local_tracking_mask_type",
                "local_fa_tracking_mask_threshold":"$params.local_fa_tracking_mask_threshold",
                "run_local_tracking":"$params.run_local_tracking",
                "local_compress_streamlines":"$params.local_compress_streamlines",
                "pft_random_seed":"$params.pft_random_seed",
                "local_algo":"$params.local_algo",
                "local_seeding":"$params.local_seeding",
                "local_nbr_seeds":"$params.local_nbr_seeds",
                "local_step":"$params.local_step",
                "local_theta":"$params.local_theta",
                "local_sfthres":"$params.local_sfthres",
                "local_sfthres_init":"$params.local_sfthres_init",
                "local_min_len":"$params.local_min_len",
                "local_max_len":"$params.local_max_len",
                "local_compress_value":"$params.local_compress_value",
                "local_random_seed":"$params.local_random_seed",
                "local_batch_size_gpu":"$params.local_batch_size_gpu",
                "local_tracking_gpu":"$params.local_tracking_gpu",
                "cpu_count":"$cpu_count",
                "template_t1":"$params.template_t1",
                "processes_brain_extraction_t1":"$params.processes_brain_extraction_t1",
                "processes_denoise_dwi":"$params.processes_denoise_dwi",
                "processes_denoise_t1":"$params.processes_denoise_t1",
                "processes_eddy":"$params.processes_eddy",
                "processes_fodf":"$params.processes_fodf",
                "processes_registration":"$params.processes_registration",
                "processes_local_tracking":"$params.processes_local_tracking"]

    engine = new groovy.text.SimpleTemplateEngine()
    template = engine.createTemplate(usage.text).make(bindings)

    print template.toString()
    return
}


workflow{



    log.info "TractoFlow pipeline"
    log.info "==================="
    log.info ""
    log.info "Start time: $workflow.start"
    log.info ""



    if (params.dti_shells){
        log.info "DTI shells extracted: $params.dti_shells"
    }
    else{
    log.info "Max DTI shell extracted: $params.max_dti_shell_value"
    }

    if (params.fodf_shells){
        log.info "FODF shells extracted: $params.fodf_shells"
    }
    else{
    log.info "Min FODF shell extracted: $params.min_fodf_shell_value"
    }

    labels_for_reg = Channel.empty()
    freesurfer_path = Channel.from("")
    bidsignore_path = Channel.from("")
    rev_b0_for_topup = Channel.empty()
    check_simple_rev_b0 = Channel.empty()


    if (params.input && !(params.bids && params.bids_config)) {
        log.info "Input: ${params.input}"

        def root = file(params.input)   // returns a file system object



        data = Channel
        .fromFilePairs("$root/**/*{bval,bvec,dwi.nii.gz,t1.nii.gz}",
                    size: 4,
                    maxDepth:1,
                    flat: true) 
        { it.parent.name }


        data.map { it -> [ it[0] ] }   // it is the tuple (sid, _, bval, ...)
            .set { ch_sid_dwi }

        Channel
            .fromFilePairs("$root/**/*{aparc+aseg.nii.gz,wmparc.nii.gz}", size: 2, maxDepth: 1, flat: true)
            { it.parent.name }
            .set { labels_for_reg }

        data
            .map { it -> 
                [it[0], "_", it[1..3], it[4], params.readout, params.encoding_direction].flatten()
            }
            .set { in_data }

        data
            .map { it -> 
                [it[0], "_", it[1..3], it[4], params.readout, params.encoding_direction].flatten()
            }
            .set { check_subjects_number }



        rev_b0_for_topup = Channel
            .fromPath("$root/**/*rev_b0.nii.gz", maxDepth: 1)
            .map { tuple(it.parent.name, it) }

        check_simple_rev_b0 = rev_b0_for_topup.map { it[0] }
        sid_rev_b0_included = rev_b0_for_topup.map { it[0] }
        sid_rev_b0_included_for_eddy_topup = rev_b0_for_topup.map { it[0] }
        sid_rev_b0_for_prepare_topup_dwi = rev_b0_for_topup.map { it[0] }

        

        Channel.empty().set { sid_rev_dwi_included }
        Channel.empty().set { sid_rev_dwi_included_for_eddy }
        Channel.empty().set { sid_rev_dwi_for_prepare_topup_for_dwi }
        Channel.empty().set { sid_rev_dwi_included_for_topup }
        Channel.empty().set { sid_rev_dwi_for_topup}
        Channel.empty().set { check_rev_number }
        Channel.empty().set { ch_sid_b0 }
        Channel.empty().set { complex_rev_b0_for_topup }
        Channel.empty().set { check_complex_rev_b0 }

    } else if (params.bids || params.bids_config) {
        if (!params.bids_config) {
            log.info "Input BIDS: $params.bids"
            if (params.fs) {
                freesurfer_path = file(params.fs)
                log.info "Freesurfer path: $params.fs"
            }
            if (params.bidsignore) {
                bidsignore_path = file(params.bidsignore)
                log.info "BIDSignore path: $params.bidsignore"
            }

            log.info "Clean_bids: $params.clean_bids"
            log.info ""

            bids = file(params.bids)
            bids_struct = Channel.empty()
            Read_BIDS(bids, freesurfer_path, bidsignore_path) |  bids_struct 

        } else {
            log.info "BIDS config: $params.bids_config"
            config = file(params.bids_config)
            bids_struct = Channel.from(config)
        }

        ch_sid_rev_dwi = Channel.empty()
        ch_sid_rev_b0 = Channel.empty()
        ch_in_data = Channel.empty()
        ch_simple_rev_b0 = Channel.empty()
        ch_complex_rev_b0 = Channel.empty()

        bids_struct.map{it ->
            def jsonSlurper = new groovy.json.JsonSlurper()
                data = jsonSlurper.parseText(it.text)
            }
            .flatMap { parsedData -> 
            parsedData.collect { item ->
                def sid = "sub-" + item.subject

                if (item.session) {
                    sid += "_ses-" + item.session
                }

                if (item.run) {
                    sid += "_run-" + item.run
                }

                item.keySet().each { key ->
                    if (item[key] == 'todo') {
                        error "Error ~ Please look at your tractoflow_bids_struct.json " +
                                "in Read_BIDS folder.\nPlease fix todo fields and give " +
                                "this file in input using --bids_config option instead of " +
                                "using --bids."
                    } else if (item[key] == 'error_readout') {
                        error "Error ~ Please look at your tractoflow_bids_struct.json " +
                                "in Read_BIDS folder.\nPlease fix error_readout fields. " +
                                "This error indicates that readout time looks wrong.\n" +
                                "Please correct the value or remove the subject in the json and " +
                                "give the updated file in input using --bids_config option instead of " +
                                "using --bids."
                    }
                }

                def sub = [sid, "_", file(item.bval), file(item.bvec), file(item.dwi),
                        file(item.t1), item.TotalReadoutTime, item.DWIPhaseEncodingDir[0]]

                ch_in_data = Channel.fromList(sub)
                ch_sid_dwi = Channel.fromList([sid])
                if(item.rev_topup) {
                    ch_sid_rev_b0 = Channel.fromList([sid])
                    if(item.topup) {
                        ch_sid_b0 = Channel.fromList([sid])
                        def sub_complex_rev_b0 = [sid, file(item.rev_topup), file(item.topup)]
                        ch_complex_rev_b0 = Channel.fromList(sub_complex_rev_b0)
                    }
                    else{
                        def sub_simple_rev_b0 = [sid, file(item.rev_topup)]
                        ch_simple_rev_b0 = Channel.fromList(sub_simple_rev_b0)
                    }
                }
                if(item.rev_dwi){
                    def ch_rev_in_data = [sid, "_rev_", file(item.rev_bval), file(item.rev_bvec), file(item.rev_dwi),
                                        file(item.t1), item.TotalReadoutTime, item.DWIPhaseEncodingDir[0]]
                    ch_sid_rev_dwi = Channel.fromList([sid])
                    ch_in_data = Channel.fromList(ch_rev_in_data)
                }

                if(item.wmparc) {
                    def sub_labels_for_reg = [sid, file(item.aparc_aseg), file(item.wmparc)]
                    labels_for_reg = Channel.fromList(sub_labels_for_reg)
                }
            } 
        }


        Channel.empty().into{sid_rev_dwi_included; sid_rev_b0_for_prepare_topup_dwi; sid_rev_dwi_included_for_topup; check_rev_number}
        ch_sid_rev_dwi.into{sid_rev_dwi_included; sid_rev_dwi_included_for_topup; sid_rev_dwi_for_prepare_topup_for_dwi; sid_rev_dwi_included_for_eddy; check_rev_number}
        ch_sid_rev_b0.into{sid_rev_b0_included; sid_rev_dwi_for_topup; sid_rev_b0_included_for_eddy_topup; sid_rev_b0_for_prepare_topup_dwi}
        ch_in_data.into{in_data; check_subjects_number}

        ch_simple_rev_b0.into{rev_b0_for_topup; check_simple_rev_b0}
        ch_complex_rev_b0.into{complex_rev_b0_for_topup; check_complex_rev_b0}

    }
    else {
        error "Error ~ Please use --input, --bids or --bids_config for the input data."
    }
    check_subjects_number.map{[it[0]]}.unique().set{unique_subjects_number}

    if (params.sh_fitting && !params.sh_fitting_shells){
        error "Error ~ Please set the SH fitting shell to use."
    }

    if (params.pft_seeding_mask_type != "wm" && params.pft_seeding_mask_type != "interface" && params.pft_seeding_mask_type != "fa"){
        error "Error ~ --pft_seeding_mask_type can only take wm, interface or fa. Please select one of these choices"
    }

    if (params.local_seeding_mask_type != "wm" && params.local_seeding_mask_type != "fa"){
        error "Error ~ --local_seeding_mask_type can only take wm or fa. Please select one of these choices"
    }

    if (params.local_tracking_mask_type != "wm" && params.local_tracking_mask_type != "fa"){
        error "Error ~ --local_tracking_mask_type can only take wm or fa. Please select one of these choices"
    }

    if (params.local_algo != "det" && params.local_algo != "prob"){
        error "Error ~ --local_algo can only take det or prob. Please select one of these choices"
    }

    if (params.pft_algo != "det" && params.pft_algo != "prob"){
        error "Error ~ --pft_algo can only take det or prob. Please select one of these choices"
    }

    if (params.local_seeding != "nt" && params.local_seeding != "npv"){
        error "Error ~ --local_seeding can only take nt or npv. Please select one of these choices"
    }

    if (params.pft_seeding != "nt" && params.pft_seeding != "npv"){
        error "Error ~ --pft_seeding can only take nt or npv. Please select one of these choices"
    }

    if (params.run_pft_tracking && workflow.profile.contains("ABS")){
        error "Error ~ PFT tracking cannot be run with Atlas Based Segmentation (ABS) profile"
    }

    if (params.bids && workflow.profile.contains("ABS") && !params.fs){
        error "Error ~ --bids parameter cannot be run with Atlas Based Segmentation (ABS) profile"
    }


    t1_for_denoise = Channel.empty()
    t1_for_test_denoise = Channel.empty()
    rev_b0_counter = Channel.empty()
    number_rev_b0_for_compare = Channel.empty()
    number_subj_for_null_check = Channel.empty()
    number_subj_for_compare = Channel.empty()
    number_rev_dwi = Channel.empty()
    rev_dwi_counter = Channel.empty()
    truc = Channel.empty()


    all_info_ch = in_data
            .map { sid, rev_flag, bvals, bvecs, dwi_v, t1_v, readout, encoding ->
                def dwi = tuple(sid, rev_flag, dwi_v)
                def gradients    = tuple(sid, rev_flag, bvals, bvecs)
                def t1     = tuple(sid, t1_v)
                def readout_encoding = tuple(sid, readout, encoding)

                return [ dwi,gradients,t1,readout_encoding ]
            } 


    t1_for_denoise = all_info_ch.map{it[2]}.unique()
    t1_for_test_denoise = all_info_ch.map{it[2]}.unique()
    rev_b0_counter = check_complex_rev_b0.concat(check_simple_rev_b0).count()
    number_rev_b0_for_compare = check_complex_rev_b0.concat(check_simple_rev_b0).count()
    number_subj_for_null_check = unique_subjects_number.count()
    number_subj_for_compare = unique_subjects_number.count()




    number_rev_dwi = check_rev_number.count()
    rev_dwi_counter = check_rev_number.count()

    if (params.eddy_cmd == "eddy_cpu" && params.processes_eddy == 1 && params.run_eddy == true){
    number_rev_dwi
        .subscribe{a -> if (a>0)
        error "Error ~ You have some subjects with a reverse encoding DWI.\n" + 
            "Eddy will take forever to run with this configuration. \nPlease add " + 
            "-profile use_gpu with a GPU environnement (GPU NVIDIA with cuda) OR increase the number " + 
            "of processes for this task (--processes_eddy) to be able to analyse this data."}
    }

    if (!params.run_topup || !params.run_eddy){
    number_rev_dwi
        .subscribe{a -> if (a>0)
        error "Error ~ You have some subjects with a reverse encoding DWI. You MUST run topup and eddy with this kind of acquisition."}
    }

    number_subj_for_null_check
    .subscribe{a -> if (a == 0)
        error "Error ~ No subjects found. Please check the naming convention, your --input path or your BIDS folder."}

    if (params.set_frf && params.mean_frf){
        error "Error ~ --set_frf and --mean_frf are activated. Please choose only one of these options. "
    }

    if (params.run_topup){
    number_subj_for_compare
        .concat(number_rev_b0_for_compare)
        .toList()
        .subscribe{a, b -> if (a != b && b > 0)
        error "Error ~ Some subjects have a reversed phase encoded b=0 and others don't.\n" +
            "Please be sure to have the same acquisitions for all subjects."}
    }

    dwi_for_prelim_bet = all_info_ch.map{it[0]}
    dwi_for_denoise = all_info_ch.map{it[0]}
    dwi_for_test_denoise = all_info_ch.map{it[0]}
    truc = all_info_ch.map{it[0]}

    if (params.pft_random_seed instanceof String){
        pft_random_seed = params.pft_random_seed?.tokenize(',')
    }
    else{
        pft_random_seed = params.pft_random_seed
    }

    if (params.local_random_seed instanceof String){
        local_random_seed = params.local_random_seed?.tokenize(',')
    }
    else{
        local_random_seed = params.local_random_seed
    }

    gradients_for_prelim_bet = all_info_ch.map{it[1]}
    gradients_for_eddy = all_info_ch.map{it[1]}
    gradients_for_prepare_topup = all_info_ch.map{it[1]}
    gradients_for_prepare_dwi_for_eddy = all_info_ch.map{it[1]}
    gradients_for_eddy_topup = all_info_ch.map{it[1]} 
    gradients_for_test_eddy_topup = all_info_ch.map{it[1]}

    readout_encoding_for_topup = all_info_ch.map{it[3]}
    readout_encoding_for_eddy = all_info_ch.map{it[3]}
    readout_encoding_for_eddy_topup = all_info_ch.map{it[3]}

    ch_sid_dwi_for_rev = ch_sid_dwi
    ch_sid_dwi_for_dwi = ch_sid_dwi


    README()


    dwi_for_prelim_bet
        .combine(gradients_for_prelim_bet, by: [0,1])
        .set{dwi_gradient_for_prelim_bet}

    b0_mask_for_eddy = Channel.empty()
    dwi_denoised_for_mix = Channel.empty()
    dwi_gibbs_for_mix = Channel.empty()


    (b0_mask_for_eddy,_,_) = Bet_Prelim_DWI(dwi_gradient_for_prelim_bet, rev_b0_counter, rev_dwi_counter)

    dwi_denoised_for_mix = Denoise_DWI(dwi_for_denoise)

    dwi_for_test_denoise
        .map{it -> if(!params.run_dwi_denoising){it}}
        .mix(dwi_denoised_for_mix)
        .set{dwi_for_gibbs}

    

    dwi_gibbs_for_mix = Gibbs_correction(dwi_for_gibbs)
    dwi_for_gibbs
        .map{it -> if(!params.run_gibbs_correction){it}}
        .mix(dwi_gibbs_for_mix)
        .set{dwi_for_eddy}

    
    dwi_for_eddy.set{dwi_for_topup}
    dwi_for_eddy.set{dwi_for_eddy_topup}
    dwi_for_eddy.set{dwi_for_test_eddy_topup}

    


    ch_sid_b0
    .mix(ch_sid_dwi_for_dwi)
    .collect()
    .map { it
            // Group by sid
            .groupBy { it }
            // Check size
            .collect { key, values -> [key, values.size()] }
            // Take only the sid appearing one time (they don't have a b0)
            .findAll { it[1] == 1}
    }
    .flatMap()
    .map {[it[0]]}
    .join(sid_rev_b0_for_prepare_topup_dwi.concat(sid_rev_dwi_for_prepare_topup_for_dwi))
    .map {[it, "_"]}
    .set{sid_dwi_for_prepare_topup}

    

    sid_rev_b0_included
    .mix(sid_rev_dwi_included)
    .collect()
    .map { it
            // Group by sid
            .groupBy { it }
            // Check size
            .collect { key, values -> [key, values.size()] }
            // Take only the sid appearing one time (they don't have a b0)
            .findAll { it[1] == 1 }
    }
    .flatMap()
    .map {[it[0]]}
    .join(sid_rev_dwi_included_for_topup)
    .map{[it, "_rev_"]}
    .set{sid_rev_dwi_for_prepare_topup}

    dwi_for_topup
    .combine(sid_dwi_for_prepare_topup.concat(sid_rev_dwi_for_prepare_topup), by: [0,1])
    .join(gradients_for_prepare_topup)
    .map{ [it[0], it[1], it[2], it[4], it[5]] }
    .set{dwi_gradients_rev_b0_for_prepare_topup}

    simple_b0_for_topup = Channel.empty()

    simple_b0_for_topup = Prepare_for_Topup(dwi_gradients_rev_b0_for_prepare_topup)

    simple_b0_for_topup
    .branch{
        forward_b0: it[2] == "_"
            return it[0..1]
        reverse_b0: it[2] == "_rev_"
            return it[0..1]
    }
    .set{branch_b0_for_topup}

    branch_b0_for_topup.reverse_b0
    .mix(rev_b0_for_topup)
    .join(branch_b0_for_topup.forward_b0)
    .mix(complex_rev_b0_for_topup)
    .join(readout_encoding_for_topup)
    .set{rev_b0_with_readout_encoding_for_topup}


    topup_files_for_eddy_topup = Channel.empty()

    (topup_files_for_eddy_topup,_,_) = Topup(rev_b0_with_readout_encoding_for_topup)


    dwi_for_eddy_topup.set{complex_dwi_for_eddy_topup}
    dwi_for_eddy_topup.set{simple_dwi_for_eddy_topup}

    // Extract subjects with reverse DWI for Prepare_dwi_for_eddy
    complex_dwi_for_eddy_topup
        .join(gradients_for_prepare_dwi_for_eddy)
        .map{[it[0], it[1], it[2], it[4], it[5]]}
        .set{dwi_gradient_for_prepare_dwi_for_eddy}

    sid_rev_dwi_included_for_eddy
        .combine(dwi_gradient_for_prepare_dwi_for_eddy, by: 0)
        .branch{
            forward_dwi: it[1] == "_"
                return [it[0]] + it[2..-1]
            reverse_dwi: it[1] == "_rev_"
                return [it[0]] + it[2..-1]
        }
        .set{branch_dwi_gradient_for_prepare_dwi_for_eddy}

    branch_dwi_gradient_for_prepare_dwi_for_eddy.forward_dwi
        .join(branch_dwi_gradient_for_prepare_dwi_for_eddy.reverse_dwi)
        .set{dwi_rev_gradient_for_prepare_dwi_for_eddy}

    concatenated_dwi_for_eddy = Channel.empty()
    
    concatenated_dwi_for_eddy = Prepare_dwi_for_eddy(dwi_rev_gradient_for_prepare_dwi_for_eddy) 

    // Extract subjects with reverse b0 images for Eddy
    expl1 = Channel.value(0)

    gradients_for_eddy_topup
        .filter{ it[1] == "_" }
        .set{simple_gradients_for_eddy_topup}

    sid_rev_b0_included_for_eddy_topup
        .combine(simple_dwi_for_eddy_topup, by: 0)
        .filter{ it[1] == "_" }
        .join(simple_gradients_for_eddy_topup)
        .merge(expl1)
        .map{[it[0], it[2], it[4], it[5], it[6]]}
        .set{simple_dwi_gradients_for_eddy_topup}

    concatenated_dwi_for_eddy
        .mix(simple_dwi_gradients_for_eddy_topup)
        .map{ [it[0], it[1], it[2], it[3], it[4]] }
        .join(topup_files_for_eddy_topup)
        .join(readout_encoding_for_eddy_topup)
        .set{dwi_gradients_mask_topup_files_for_eddy_topup}


    (dwi_from_eddy_topup,gradients_from_eddy_topup,_) = Eddy_Topup(dwi_gradients_mask_topup_files_for_eddy_topup, rev_b0_counter, rev_dwi_counter)

    dwi_for_eddy
        .combine(gradients_for_eddy, by: [0,1])
        .filter{ it[1] == "_" }
        .map{ [it[0], it[2], it[3], it[4]] }
        .join(b0_mask_for_eddy)
        .join(readout_encoding_for_eddy)
        .set{dwi_gradients_mask_topup_files_for_eddy}

    (dwi_from_eddy, gradients_from_eddy) = Eddy(dwi_gradients_mask_topup_files_for_eddy, rev_b0_counter, rev_dwi_counter)

    dwi_for_test_eddy_topup
        .map{it -> if(!params.run_eddy){it}}
        .filter{ it[1] == "_" }
        .map{ [it[0], it[2]] }
        .set{dwi_for_skip_eddy_topup}

    gradients_for_test_eddy_topup
        .map{it -> if(!params.run_eddy){it}}
        .filter{ it[1] == "_" }
        .map{ [it[0], it[2], it[3]] }
        .set{gradients_for_skip_eddy_topup}

    dwi_from_eddy
        .mix(dwi_from_eddy_topup)
        .mix(dwi_for_skip_eddy_topup)
        .set{dwi_for_bet}

    gradients_from_eddy
        .mix(gradients_from_eddy_topup)
        .mix(gradients_for_skip_eddy_topup)
        .set{gradients_for_extract_b0}
    
    gradients_for_extract_b0.set{gradients_for_dti_shell}
    gradients_for_extract_b0.set{gradients_for_fodf_shell}
    gradients_for_extract_b0.set{gradients_for_normalize}
    gradients_for_extract_b0.set{gradients_for_bet}
    gradients_for_extract_b0.set{gradients_for_sh_fitting_shell}

    dwi_for_bet
        .join(gradients_for_bet)
        .set{dwi_gradients_for_bet}
    

    (b0_and_mask_for_crop, dwi_b0_b0_mask_for_n4, _) = Bet_DWI(dwi_gradients_for_bet)

    dwi_for_crop = N4_DWI(dwi_b0_b0_mask_for_n4)

    dwi_for_crop
        .join(b0_and_mask_for_crop)
        .set{dwi_and_b0_mask_b0_for_crop}

    (dwi_mask_for_normalize, mask_for_resample, _) = Crop_DWI(dwi_and_b0_mask_b0_for_crop)

    t1_for_mix_n4 = Channel.empty()
    t1_for_mix_n4 = Denoise_T1(t1_for_denoise)

    t1_for_test_denoise
        .map{it -> if(!params.run_t1_denoising){it}}
        .mix(t1_for_mix_n4)
        .set{t1_for_n4}

    t1_for_resample = Channel.empty()
    t1_for_resample = N4_T1(t1_for_n4)
    t1_for_resample.set{t1_for_test_resample}

    t1_resampled_for_mix = Channel.empty()
    t1_resampled_for_mix = Resample_T1(t1_for_resample) 

    t1_for_test_resample
        .map{it -> if(!params.run_resample_t1){it}}
        .mix(t1_resampled_for_mix)
        .set{t1_for_bet}

    t1_and_mask_for_crop = Channel.empty()
    t1_and_mask_for_crop = Bet_T1(t1_for_bet)

    t1_and_mask_for_crop = Channel.empty()
    t1_and_mask_for_reg = Crop_T1(t1_and_mask_for_crop)

    dwi_mask_for_normalize
        .join(gradients_for_normalize)
        .set{dwi_mask_grad_for_normalize}
    
    
    (dwi_for_resample,_) = Normalize_DWI(dwi_mask_grad_for_normalize)
    dwi_for_resample.set{dwi_for_test_resample}

    dwi_for_resample
        .join(mask_for_resample)
        .set{dwi_mask_for_resample}

    dwi_resampled_for_mix = Channel.empty()
    dwi_resampled_for_mix = Resample_DWI(dwi_mask_for_resample)

    dwi_for_test_resample
        .map{it -> if(!params.run_resample_dwi){it}}
        .mix(dwi_resampled_for_mix)
        .set{dwi_for_extract_b0}
    
    dwi_for_extract_b0.set{dwi_for_extract_dti_shell}
    dwi_for_extract_b0.set{dwi_for_extract_fodf_shell}
    dwi_for_extract_b0.set{dwi_for_extract_sh_fitting_shell}

    dwi_for_extract_b0
        .join(gradients_for_extract_b0)
        .set{dwi_and_grad_for_extract_b0}
    
    (b0_for_reg, b0_mask_for_dti_metrics) = Extract_B0(dwi_and_grad_for_extract_b0)

    b0_mask_for_dti_metrics.set{b0_mask_for_fodf}
    b0_mask_for_dti_metrics.set{b0_mask_for_rf}
    
    dwi_for_extract_sh_fitting_shell
        .join(gradients_for_sh_fitting_shell)
        .set{dwi_and_grad_for_extract_sh_fitting_shell}

    dwi_and_grad_for_sh_fitting = Channel.empty()
    dwi_and_grad_for_sh_fitting = Extract_SH_Fitting_Shell(dwi_and_grad_for_extract_sh_fitting_shell)

    SH_Fitting(dwi_and_grad_for_sh_fitting)

    dwi_for_extract_dti_shell
        .join(gradients_for_dti_shell)
        .set{dwi_and_grad_for_extract_dti_shell}

    dwi_and_grad_for_dti_metrics =  Channel.empty()
    dwi_and_grad_for_dti_metrics = Extract_DTI_Shell(dwi_and_grad_for_extract_dti_shell)
    dwi_and_grad_for_dti_metrics.set{dwi_and_grad_for_rf}

    dwi_and_grad_for_dti_metrics
        .join(b0_mask_for_dti_metrics)
        .set{dwi_and_grad_for_dti_metrics}

    def dti_metrics_results = DTI_Metrics(dwi_and_grad_for_dti_metrics)
    def fa_md_for_fodf = dti_metrics_results.fa_md_for_fodf
    def fa_for_reg = dti_metrics_results.fa_for_reg
    def fa_for_pft_tracking = dti_metrics_results.fa_for_reg
    def fa_for_local_tracking_mask = dti_metrics_results.fa_for_reg
    def fa_for_local_seeding_mask = dti_metrics_results.fa_for_reg

    dwi_for_extract_fodf_shell
        .join(gradients_for_fodf_shell)
        .set{dwi_and_grad_for_extract_fodf_shell}

    def dwi_and_grad_for_fodf = Extract_FODF_Shell(dwi_and_grad_for_extract_fodf_shell)

    t1_and_mask_for_reg
        .join(fa_for_reg)
        .join(b0_for_reg)
        .set{t1_fa_b0_for_reg}


}

workflow rest {
    


    register_t1() 

    labels_for_reg
        .join(t1_for_freesurfer_reg)
        .set{labels_mat_for_reg}

    register_freesurfer()

    segment_freesurfer() 

    segment_tissues() 

    wm_mask_freesurfer
        .concat(wm_mask_fast)
        .into{wm_mask_for_local_tracking_mask;wm_mask_for_local_seeding_mask}

    dwi_and_grad_for_rf
        .join(b0_mask_for_rf)
        .set{dwi_b0_for_rf}

    compute_frf() 

    all_frf_to_collect
        .collect()
        .set{all_frf_for_mean_frf}

    mean_frf_workflow() 

    frf_for_fodf = unique_frf

    if (params.mean_frf) {
        frf_for_fodf = unique_frf_for_mean
                    .merge(mean_frf)
                    .map{it -> [it[0], it[2]]}
    }

    dwi_and_grad_for_fodf
        .join(b0_mask_for_fodf)
        .join(fa_md_for_fodf)
        .join(frf_for_fodf)
        .set{dwi_b0_metrics_frf_for_fodf}

    fodf_metrics() 

    pft_tracking_maps() 

    wm_mask_for_pft_tracking
        .join(fa_for_pft_tracking)
        .join(interface_for_pft_seeding_mask)
        .set{wm_fa_int_for_pft}

    pft_seeding_mask()

    fodf_for_pft_tracking
        .join(pft_maps_for_pft_tracking)
        .join(seeding_mask_for_pft)
        .set{fodf_maps_for_pft_tracking}

    pft_tracking() 

    wm_mask_for_local_tracking_mask
        .join(fa_for_local_tracking_mask)
        .set{wm_fa_for_local_tracking_mask}

    local_tracking_mask() 

    wm_mask_for_local_seeding_mask
        .join(fa_for_local_seeding_mask)
        .set{wm_fa_for_local_seeding_mask}

    local_seeding_mask() 

    fodf_for_local_tracking
        .join(tracking_mask_for_local)
        .join(tracking_seeding_mask_for_local)
        .set{fodf_maps_for_local_tracking}

    local_tracking()
}

workflow.onComplete {
        log.info "Pipeline completed at: $workflow.complete"
        log.info "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
        log.info "Execution duration: $workflow.duration"
    }
