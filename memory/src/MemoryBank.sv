`include "../../core/src/Bundle.sv"
module MemoryBank(input clk,
		  input        Bundle::MemoryBankIn request, 
		  output       Bundle::MemoryBankOut response
);

   Register#(.width($bits(grant2)))  mem_req_grant(.clk(clk), .in(grant2), .out(grant2_1));
   MemorySim memory();   
endmodule
