set scenario "all"
if {$argc >= 1} {
    set scenario [lindex $argv 0]
}

proc fail {message} {
    puts stderr $message
    catch {close_sim -force}
    catch {close_project}
    exit 1
}

proc ensure_project {repo_root} {
    set xpr_path [file join $repo_root rv32i vivado_projekat vivado_projekat.xpr]
    puts "Regenerating Vivado project from RISCV.tcl..."
    source [file join $repo_root RISCV.tcl]
    if {![file exists $xpr_path]} {
        fail "Vivado projekat nije napravljen: $xpr_path"
    }
}

proc clean_xsim_dir {repo_root} {
    set xsim_dir [file join $repo_root rv32i vivado_projekat vivado_projekat.sim sim_1 behav xsim]
    if {[file exists $xsim_dir]} {
        if {[catch {file delete -force $xsim_dir} result]} {
            puts "WARNING: xsim folder nije ociscen, nastavljam: $result"
        }
    }
}

proc run_synthesis_check {} {
    puts "Running Vivado synthesis check..."
    set_property top TOP_RISCV [get_filesets sources_1]
    reset_run synth_1
    launch_runs synth_1 -jobs 4
    wait_on_run synth_1

    set synth_run [get_runs synth_1]
    set status [get_property STATUS $synth_run]
    puts "SYNTH_STATUS=$status"
    if {[string first "Complete" $status] < 0} {
        fail "Vivado synthesis nije uspjesno zavrsena."
    }
}

proc run_behavioral_sim_check {repo_root top_name generic_string} {
    puts "Running Vivado behavioral simulation for $top_name..."
    set sim_fileset [get_filesets sim_1]
    set_property top $top_name $sim_fileset
    set_property top_lib xil_defaultlib $sim_fileset
    set_property generic $generic_string $sim_fileset
    update_compile_order -fileset sim_1
    clean_xsim_dir $repo_root

    if {[catch {
        launch_simulation -simset sim_1 -mode behavioral
        restart
        run all
        close_sim -force
    } result]} {
        fail "Vivado behavioral simulation nije prosla za $top_name: $result"
    }
}

proc program_path_for_xsim {name} {
    return [file join .. .. .. .. .. testovi test_programi $name]
}

proc set_default_sim_config {} {
    set sim_fileset [get_filesets sim_1]
    set_property top TOP_testovi $sim_fileset
    set_property top_lib xil_defaultlib $sim_fileset
    set_property generic "SCENARIO_ID_G=1 PROGRAM_PATH_G=[program_path_for_xsim zbb_demo.txt]" $sim_fileset
}

set script_dir [file normalize [file dirname [info script]]]
set repo_root [file normalize [file join $script_dir ..]]

cd $repo_root
ensure_project $repo_root

switch -- $scenario {
    "all" {
        run_synthesis_check
        run_behavioral_sim_check $repo_root ALU_zbb_tb ""
        run_behavioral_sim_check $repo_root TOP_testovi "SCENARIO_ID_G=1 PROGRAM_PATH_G=[program_path_for_xsim zbb_demo.txt]"
        run_behavioral_sim_check $repo_root TOP_testovi "SCENARIO_ID_G=0 PROGRAM_PATH_G=[program_path_for_xsim rv32i_regression.txt]"
        run_behavioral_sim_check $repo_root TOP_testovi "SCENARIO_ID_G=2 PROGRAM_PATH_G=[program_path_for_xsim extended_demo.txt]"
    }
    "synth" {
        run_synthesis_check
    }
    "alu" {
        run_behavioral_sim_check $repo_root ALU_zbb_tb ""
    }
    "zbb" {
        run_behavioral_sim_check $repo_root TOP_testovi "SCENARIO_ID_G=1 PROGRAM_PATH_G=[program_path_for_xsim zbb_demo.txt]"
    }
    "rv32i" {
        run_behavioral_sim_check $repo_root TOP_testovi "SCENARIO_ID_G=0 PROGRAM_PATH_G=[program_path_for_xsim rv32i_regression.txt]"
    }
    "extended" {
        run_behavioral_sim_check $repo_root TOP_testovi "SCENARIO_ID_G=2 PROGRAM_PATH_G=[program_path_for_xsim extended_demo.txt]"
    }
    default {
        fail "Nepoznat scenario: $scenario"
    }
}

set_default_sim_config
puts "Vivado checks completed successfully."
catch {close_project}
exit 0
