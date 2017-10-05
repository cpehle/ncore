module FPUnit(
	      input 		  clk,
	      input 		  nreset, 
	      input logic [31:0]  op_a,
	      output logic 	  op_a_ready,
	      input logic 	  op_a_valid,
	      input logic [31:0]  op_b,
	      output logic 	  op_b_ready,
	      input logic 	  op_b_valid,
	      output logic [31:0] z,
	      input logic 	  z_ready,
	      output logic 	  z_valid	      
);
   
   HLS_fp32_add fp_add(/*AUTOINST*/
		       // Outputs
		       .chn_a_rsc_lz	(chn_a_rsc_lz),
		       .chn_b_rsc_lz	(chn_b_rsc_lz),
		       .chn_o_rsc_z	(chn_o_rsc_z[31:0]),
		       .chn_o_rsc_lz	(chn_o_rsc_lz),
		       // Inputs
		       .nvdla_core_clk	(nvdla_core_clk),
		       .nvdla_core_rstn	(nvdla_core_rstn),
		       .chn_a_rsc_z	(chn_a_rsc_z[31:0]),
		       .chn_a_rsc_vz	(chn_a_rsc_vz),
		       .chn_b_rsc_z	(chn_b_rsc_z[31:0]),
		       .chn_b_rsc_vz	(chn_b_rsc_vz),
		       .chn_o_rsc_vz	(chn_o_rsc_vz));

   HLS_fp32_mul fp_mul(/*AUTOINST*/
		       // Outputs
		       .chn_a_rsc_lz	(chn_a_rsc_lz),
		       .chn_b_rsc_lz	(chn_b_rsc_lz),
		       .chn_o_rsc_z	(chn_o_rsc_z[31:0]),
		       .chn_o_rsc_lz	(chn_o_rsc_lz),
		       // Inputs
		       .nvdla_core_clk	(nvdla_core_clk),
		       .nvdla_core_rstn	(nvdla_core_rstn),
		       .chn_a_rsc_z	(chn_a_rsc_z[31:0]),
		       .chn_a_rsc_vz	(chn_a_rsc_vz),
		       .chn_b_rsc_z	(chn_b_rsc_z[31:0]),
		       .chn_b_rsc_vz	(chn_b_rsc_vz),
		       .chn_o_rsc_vz	(chn_o_rsc_vz));

   HLS_fp32_sub fp_sub(/*AUTOINST*/
		       // Outputs
		       .chn_a_rsc_lz	(chn_a_rsc_lz),
		       .chn_b_rsc_lz	(chn_b_rsc_lz),
		       .chn_o_rsc_z	(chn_o_rsc_z[31:0]),
		       .chn_o_rsc_lz	(chn_o_rsc_lz),
		       // Inputs
		       .nvdla_core_clk	(nvdla_core_clk),
		       .nvdla_core_rstn	(nvdla_core_rstn),
		       .chn_a_rsc_z	(chn_a_rsc_z[31:0]),
		       .chn_a_rsc_vz	(chn_a_rsc_vz),
		       .chn_b_rsc_z	(chn_b_rsc_z[31:0]),
		       .chn_b_rsc_vz	(chn_b_rsc_vz),
		       .chn_o_rsc_vz	(chn_o_rsc_vz));
   
endmodule
// Local Variables:
// verilog-library-directories:("." "../src/" "../../fplib")
// End:
