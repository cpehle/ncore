set_app_var target_library "
	   /cad/libs/tsmc65/digital/Front_End/timing_power_noise/NLDM/tcbn65lp_200a/tcbn65lpwc.db
	   /cad/libs/tsmc65/digital/Front_End/timing_power_noise/NLDM/tpdn65lpnv2_140b/tpdn65lpnv2wc.db
	   /cad/libs/tsmc65/digital/Front_End/timing_power_noise/NLDM/tpan65lpgv2_140c/tpan65lpgv2wc.db
	   /cad/libs/tsmc/sram/ts1n65lpa4096x32m16_140a/SYNOPSYS/ts1n65lpa4096x32m16_140a_ss1p08v125c.db
	   /cad/libs/tsmc/sram/tsdn65lpa1024x32m4s_200b/SYNOPSYS/tsdn65lpa1024x32m4s_200b_ss1p08v125c.db
	   /cad/libs/tsmc/sram/ts5n65lpa32x128m2_140b/SYNOPSYS/ts5n65lpa32x128m2_140b_ss1p08v125c.db"

set_app_var link_library "
	   /cad/libs/tsmc65/digital/Front_End/timing_power_noise/NLDM/tcbn65lp_200a/tcbn65lpwc.db
	   /cad/libs/tsmc65/digital/Front_End/timing_power_noise/NLDM/tpdn65lpnv2_140b/tpdn65lpnv2wc.db
	   /cad/libs/tsmc65/digital/Front_End/timing_power_noise/NLDM/tpan65lpgv2_140c/tpan65lpgv2wc.db
	   /cad/libs/tsmc/sram/ts1n65lpa4096x32m16_140a/SYNOPSYS/ts1n65lpa4096x32m16_140a_ss1p08v125c.db
	   /cad/libs/tsmc/sram/tsdn65lpa1024x32m4s_200b/SYNOPSYS/tsdn65lpa1024x32m4s_200b_ss1p08v125c.db
	   /cad/libs/tsmc/sram/ts5n65lpa32x128m2_140b/SYNOPSYS/ts5n65lpa32x128m2_140b_ss1p08v125c.db"

set_app_var mw_logic1_net "VDD"
set_app_var mw_logic0_net "VSS"

create_mw_lib -open -tech "/cad/libs/tsmc65/digital/Back_End/milkyway/tcbn65lp_200a/techfiles/tsmcn65_9lmT2.tf" -mw_reference_library "/cad/libs/tsmc65/digital/Back_End/milkyway/tcbn65lp_200a/frame_only/tcbn65lp" "LIB"

open_mw_lib "LIB"
check_library

set_tlu_plus_files -max_tluplus "/cad/libs/tsmc65/digital/Back_End/milkyway/tcbn65lp_200a/techfiles/tluplus/cln65lp_1p09m+alrdl_rcworst_top2.tluplus" -min "/cad/libs/tsmc65/digital/Back_End/milkyway/tcbn65lp_200a/techfiles/tluplus/cln65lp_1p09m+alrdl_rcbest_top2.tluplus" -tech2itf_map "/cad/libs/tsmc65/digital/Back_End/milkyway/tcbn65lp_200a/techfiles/tluplus/star.map_9M"

check_tlu_plus_files

# turn on name mapping to help power analysis
# saif_map -start

# read in lots of files
source read_sources.tcl

elaborate Core
link
check_design

# create clocks
create_clock clk -name core_clk -period 2

# compile (can try compile_ultra aswell)

compile_ultra -gate_clock -no_autoungroup

# we can generate power estimates by using a given converting a given vcd file to saif format
# saif_map -create_map -input "../../sim/build/sort-rtl-struct-random.saif" -source_instance "TOP/v"
# saif_map -type ptpx -write_map "post-synth.namemap"

# write out result of synthesis
write -format verilog -hierarchy -output post_synth.v
write -format ddc -hierarchy -output post_synth.ddc
write_sdc post_synth.sdc

# generate various reports
report_timing -nosplit -transition_time -nets -attributes
report_area -nosplit -hierarchy
report_power -nosplit -hierarchy
