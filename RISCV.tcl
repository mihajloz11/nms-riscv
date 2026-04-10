#process for getting script file directory
variable dispScriptFile [file normalize [info script]]
proc getScriptDirectory {} {
    variable dispScriptFile
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}

#change working directory to script file directory
cd [getScriptDirectory]
#set project directory
set projectDir .\/RV32I/RISCV_project

file mkdir $projectDir

set localBoardRepo "C:/Users/mihaj/Downloads/vivado-boards-master/vivado-boards-master/new/board_files"

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

# MAKE A PROJECT
create_project RISCV_project $projectDir -part xc7z010clg400-1 -force
if {$zyboBoardPart ne ""} {
    set_property board_part $zyboBoardPart [current_project]
}

add_files -norecurse ./RV32I/TOP_RISCV.vhd 
add_files -norecurse ./RV32I/control_path/alu_decoder.vhd 
add_files -norecurse ./RV32I/data_path/immediate.vhd 
add_files -norecurse ./RV32I/data_path/ALU_simple.vhd 
add_files -norecurse ./RV32I/data_path/register_bank.vhd 
add_files -norecurse ./RV32I/control_path/control_path.vhd 
add_files -norecurse ./RV32I/control_path/ctrl_decoder.vhd 
add_files -norecurse ./RV32I/data_path/data_path.vhd
add_files -norecurse ./RV32I/packages/alu_ops_pkg.vhd 
add_files -norecurse ./RV32I/packages/txt_util.vhd
update_compile_order -fileset sources_1
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ./RV32I/RISCV_tb/BRAM_byte_addressable.vhd
add_files -fileset sim_1 -norecurse ./RV32I/RISCV_tb/ALU_zbb_tb.vhd
add_files -fileset sim_1 -norecurse ./RV32I/RISCV_tb/TOP_RISCV_tb.vhd
add_files -fileset sim_1 -norecurse ./RV32I/RISCV_project/TOP_RISCV_tb_behav.wcfg

set_property top TOP_RISCV_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property generic {SCENARIO_ID_G=1} [get_filesets sim_1]
set_property runtime 12000ns [get_filesets sim_1]
set_property xsim.simulate.runtime 12000ns [get_filesets sim_1]
set_property xsim.view [file normalize ./RV32I/RISCV_project/TOP_RISCV_tb_behav.wcfg] [get_filesets sim_1]

update_compile_order -fileset sim_1


