`include "Bundle.sv"
module Alu(input Bundle::AluIn alu_in,
           output Bundle::AluOut alu_out);
   import Bundle::*;
   always_comb begin
   case (alu_in.fun) inside
     ALU_ADD:
       alu_out.data = alu_in.op1 + alu_in.op2;
     ALU_SUB:
       alu_out.data = alu_in.op1 - alu_in.op2;
     ALU_AND:
       alu_out.data = alu_in.op1 & alu_in.op2;
     ALU_OR:
       alu_out.data = alu_in.op1 | alu_in.op2;
     ALU_XOR:
       alu_out.data = alu_in.op1 ^ alu_in.op2;
     ALU_SLT:
       alu_out.data = {31'b0, alu_in.op1 < alu_in.op2};
     ALU_SLTU:
       alu_out.data = {31'b0, alu_in.op1 < alu_in.op2};
     ALU_SLL:
       alu_out.data = alu_in.op1 << alu_in.op2[4:0];
     ALU_SRA:
       alu_out.data = alu_in.op1 >> alu_in.op2[4:0];
     ALU_SRL:
       alu_out.data = alu_in.op1 >> alu_in.op2;
     default:
       alu_out.data = 32'bx;
   endcase // case (alu_in.fun)
   end
endmodule; // Alu
