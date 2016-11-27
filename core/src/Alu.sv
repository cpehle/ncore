//@file Alu.sv
//@author Christian Pehle
//@brief
`include "Bundle.sv"
module Alu(input Bundle::AluIn alu_in,
           output Bundle::AluOut alu_out);
   always_comb begin
   case (alu_in.fun) inside
     Bundle::ALU_ADD:
       alu_out.data = alu_in.op1 + alu_in.op2;
     Bundle::ALU_SUB:
       alu_out.data = alu_in.op1 - alu_in.op2;
     Bundle::ALU_AND:
       alu_out.data = alu_in.op1 & alu_in.op2;
     Bundle::ALU_OR:
       alu_out.data = alu_in.op1 | alu_in.op2;
     Bundle::ALU_XOR:
       alu_out.data = alu_in.op1 ^ alu_in.op2;
     Bundle::ALU_SLT:
       alu_out.data = {31'b0, alu_in.op1 < alu_in.op2};
     Bundle::ALU_SLTU:
       alu_out.data = {31'b0, alu_in.op1 < alu_in.op2};
     Bundle::ALU_SLL:
       alu_out.data = alu_in.op1 << alu_in.op2[4:0];
     Bundle::ALU_SRA:
       alu_out.data = alu_in.op1 >> alu_in.op2[4:0];
     Bundle::ALU_SRL:
       alu_out.data = alu_in.op1 >> alu_in.op2;
     Bundle::ALU_COPY_1:
       alu_out.data = alu_in.op1;
     Bundle::ALU_COPY_2:
       alu_out.data = alu_in.op2;
     default:
       alu_out.data = 32'bx;
   endcase // case (alu_in.fun)
   end
endmodule // Alu
