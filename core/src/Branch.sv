`include "Bundle.sv"
module Branch(
	      input  clk,
              input  Bundle::BranchIn branch_in,
	      input  logic fence_i,
              output Bundle::BranchOut branch_out
);
   import Bundle::*;

   logic 	     fence_i_reg;

   Register #(.width(1)) fenci_reg(.out(fence_i_reg),
				   .in(fence_i),
				   /*AUTOINST*/
				   // Inputs
				   .clk			(clk));
      
   PcSel pc_sel_reg;
   always_ff @(posedge clk) begin
      pc_sel_reg <= branch_in.pipeline_kill ? PC_EXC :
		    (branch_in.br_type == BR_N) ? PC_4 :
		    (branch_in.br_type == BR_NE) ? (!branch_in.br_eq ? PC_BRJMP : PC_4) :
		    (branch_in.br_type == BR_EQ) ? (branch_in.br_eq ? PC_BRJMP : PC_4) :
		    (branch_in.br_type == BR_GE) ? (!branch_in.br_lt ? PC_BRJMP : PC_4) :
		    (branch_in.br_type == BR_GEU) ? (!branch_in.br_ltu ? PC_BRJMP : PC_4) :
		    (branch_in.br_type == BR_LT) ? (branch_in.br_lt ? PC_BRJMP : PC_4) :
		    (branch_in.br_type == BR_LTU) ? (branch_in.br_ltu ? PC_BRJMP : PC_4) :
		    (branch_in.br_type == BR_J) ? PC_BRJMP :
		    (branch_in.br_type == BR_JR) ?  PC_JALR : PC_4;
   end
   
   always_comb begin
      branch_out.pc_sel   = branch_in.pipeline_kill ? PC_EXC :
			    (branch_in.br_type == BR_N) ? PC_4 :
			    (branch_in.br_type == BR_NE) ? (!branch_in.br_eq ? PC_BRJMP : PC_4) :
			    (branch_in.br_type == BR_EQ) ? (branch_in.br_eq ? PC_BRJMP : PC_4) :
			    (branch_in.br_type == BR_GE) ? (!branch_in.br_lt ? PC_BRJMP : PC_4) :
			    (branch_in.br_type == BR_GEU) ? (!branch_in.br_ltu ? PC_BRJMP : PC_4) :
			    (branch_in.br_type == BR_LT) ? (branch_in.br_lt ? PC_BRJMP : PC_4) :
			    (branch_in.br_type == BR_LTU) ? (branch_in.br_ltu ? PC_BRJMP : PC_4) :
			    (branch_in.br_type == BR_J) ? PC_BRJMP :
			    (branch_in.br_type == BR_JR) ?  PC_JALR : PC_4;
      branch_out.if_kill  = (branch_out.pc_sel != PC_4) /* || !branch_in.imem_res_valid */ || fence_i || fence_i_reg;   
      branch_out.dec_kill = (branch_out.pc_sel != PC_4);
   end
endmodule

