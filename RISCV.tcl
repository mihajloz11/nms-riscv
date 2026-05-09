# putanja do ove skripte
variable dispScriptFile [file normalize [info script]]
proc getScriptDirectory {} {
    variable dispScriptFile
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}

# radni folder je folder skripte
cd [getScriptDirectory]
# folder vivado projekta
set projectDir .\/rv32i/vivado_projekat

file mkdir $projectDir

if {[info exists ::env(USERPROFILE)]} {
    set localBoardRepo [file normalize [file join $::env(USERPROFILE) Downloads vivado-boards-master vivado-boards-master new board_files]]
} else {
    set localBoardRepo ""
}

set zyboBoardPart ""
foreach candidate {digilentinc.com:zybo:part0:2.0 digilentinc.com:zybo-z7-10:part0:1.2 digilentinc.com:zybo-z7-10:part0:1.0} {
    if {[llength [get_board_parts $candidate]] > 0} {
        set zyboBoardPart $candidate
        break
    }
}

if {$zyboBoardPart eq "" && [file exists $localBoardRepo]} {
    set_param board.repoPaths $localBoardRepo
    foreach candidate {digilentinc.com:zybo:part0:2.0 digilentinc.com:zybo-z7-10:part0:1.2 digilentinc.com:zybo-z7-10:part0:1.0} {
        if {[llength [get_board_parts $candidate]] > 0} {
            set zyboBoardPart $candidate
            break
        }
    }
}

# pravljenje projekta
create_project vivado_projekat $projectDir -part xc7z010clg400-1 -force
if {$zyboBoardPart ne ""} {
    set_property board_part $zyboBoardPart [current_project]
}

add_files -norecurse ./rv32i/TOP_RISCV.vhd
add_files -norecurse ./rv32i/kontrola/alu_decoder.vhd
add_files -norecurse ./rv32i/podaci/immediate.vhd
add_files -norecurse ./rv32i/podaci/ALU_simple.vhd
add_files -norecurse ./rv32i/podaci/register_bank.vhd
add_files -norecurse ./rv32i/kontrola/kontrola.vhd
add_files -norecurse ./rv32i/kontrola/ctrl_decoder.vhd
add_files -norecurse ./rv32i/podaci/podaci.vhd
add_files -norecurse ./rv32i/paketi/alu_ops_pkg.vhd
add_files -norecurse ./rv32i/paketi/txt_util.vhd
update_compile_order -fileset sources_1
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ./rv32i/testovi/BRAM_byte_addressable.vhd
add_files -fileset sim_1 -norecurse ./rv32i/testovi/ALU_zbb_tb.vhd
add_files -fileset sim_1 -norecurse ./rv32i/testovi/TOP_testovi.vhd

set_property top TOP_testovi [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property generic {SCENARIO_ID_G=1 PROGRAM_PATH_G=../../../../../testovi/test_programi/zbb_demo.txt} [get_filesets sim_1]
set_property runtime 12000ns [get_filesets sim_1]
set_property xsim.simulate.runtime 12000ns [get_filesets sim_1]

update_compile_order -fileset sim_1
