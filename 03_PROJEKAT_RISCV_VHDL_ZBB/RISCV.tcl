# Prenosiva Vivado skripta za ovaj projekat.
# Pokretanje iz Vivado GUI:
#   Tools -> Run Tcl Script... -> izabrati ovaj RISCV.tcl
#
# Skripta sama nalazi folder u kojem se nalazi, napravi Vivado projekat
# u rv32i/vivado_projekat i doda sve VHDL fajlove. Ne koristi lokalne
# lokalne Windows putanje.

set script_dir [file normalize [file dirname [info script]]]
set project_name "vivado_projekat"
set project_dir [file normalize [file join $script_dir "rv32i" "vivado_projekat"]]
set project_file [file join $project_dir "$project_name.xpr"]

proc add_existing_files {fileset_name file_list} {
    set existing_files {}
    foreach file_path $file_list {
        if {![file exists $file_path]} {
            error "Nedostaje fajl: $file_path"
        }
        lappend existing_files $file_path
    }
    add_files -fileset $fileset_name -norecurse $existing_files
}

catch {close_project}
file mkdir $project_dir

create_project $project_name $project_dir -part xc7z010clg400-1 -force
set_property target_language VHDL [current_project]
set_property default_lib xil_defaultlib [current_project]

set src_files [list \
    [file join $script_dir rv32i paketi txt_util.vhd] \
    [file join $script_dir rv32i paketi alu_ops_pkg.vhd] \
    [file join $script_dir rv32i podaci ALU_simple.vhd] \
    [file join $script_dir rv32i podaci register_bank.vhd] \
    [file join $script_dir rv32i podaci immediate.vhd] \
    [file join $script_dir rv32i podaci podaci.vhd] \
    [file join $script_dir rv32i kontrola ctrl_decoder.vhd] \
    [file join $script_dir rv32i kontrola alu_decoder.vhd] \
    [file join $script_dir rv32i kontrola kontrola.vhd] \
    [file join $script_dir rv32i TOP_RISCV.vhd] \
]

set sim_files [list \
    [file join $script_dir rv32i testovi BRAM_byte_addressable.vhd] \
    [file join $script_dir rv32i testovi ALU_zbb_tb.vhd] \
    [file join $script_dir rv32i testovi TOP_testovi.vhd] \
    [file join $script_dir rv32i testovi assembly_code.txt] \
    [file join $script_dir rv32i testovi assembly_code_active.txt] \
    [file join $script_dir rv32i testovi test_programi rv32i_regression.txt] \
    [file join $script_dir rv32i testovi test_programi zbb_demo.txt] \
    [file join $script_dir rv32i testovi test_programi extended_demo.txt] \
]

add_existing_files sources_1 $src_files
add_existing_files sim_1 $sim_files

set vhdl_files [list]
foreach file_path [concat $src_files [lrange $sim_files 0 2]] {
    lappend vhdl_files [get_files $file_path]
}
set_property file_type {VHDL 2008} $vhdl_files

set_property top TOP_RISCV [get_filesets sources_1]
set_property top TOP_testovi [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Putanja je relativna iz XSim radnog foldera:
# rv32i/vivado_projekat/vivado_projekat.sim/sim_1/behav/xsim
set_property generic {SCENARIO_ID_G=1 PROGRAM_PATH_G=../../../../../testovi/test_programi/zbb_demo.txt} [get_filesets sim_1]
set_property runtime 12000ns [get_filesets sim_1]
set_property xsim.simulate.runtime 12000ns [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts ""
puts "Vivado projekat je napravljen:"
puts "  $project_file"
puts "Projekat je vec otvoren u Vivado GUI."
puts ""
puts "Za GUI provjeru sada mozes pokrenuti:"
puts "  Flow Navigator -> Simulation -> Run Simulation -> Run Behavioral Simulation"
puts ""
