`include "Bundle.sv"
module Branch(
              input  Bundle::BranchIn branch_in,
              output Bundle::BranchOut branch_out
);
   import Bundle::*;
   // Branch logic
   assign branch_out.pc_sel = branch_in.pipeline_kill ? PC_EXC :
                              (branch_in.br_type == BR_N) ? PC_4 :
                              (branch_in.br_type == BR_NE) ? (!branch_in.br_eq ? PC_BRJMP : PC_4) :
                              (branch_in.br_type == BR_EQ) ? (!branch_in.br_eq ? PC_BRJMP : PC_4) :
                              (branch_in.br_type == BR_GE) ? (!branch_in.br_eq ? PC_BRJMP : PC_4) :
                              (branch_in.br_type == BR_GEU) ? (!branch_in.br_eq ? PC_BRJMP : PC_4) :
                              (branch_in.br_type == BR_LT) ? (!branch_in.br_eq ? PC_BRJMP : PC_4) :
                              (branch_in.br_type == BR_LTU) ? (!branch_in.br_eq ? PC_BRJMP : PC_4) :
                              (branch_in.br_type == BR_J) ? (!branch_in.br_eq ? PC_BRJMP : PC_4) :
                              (branch_in.br_type == BR_JR) ?  PC_JALR : PC_4;
endmodule
