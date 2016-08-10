`include "Bundle.sv"
module Bypass(
              input Bundle::BypassIn bp_in,
              output Bundle::BypassOut bp_out
              );

   assign bp_out.alu_op2 = (bp_in.op2_sel == Bundle::OP2_RS2) ? bp_in.rs2_data :
                           (bp_in.op2_sel == Bundle::OP2_ITYPE) ? 0 : 0;




endmodule
