`include "Bundle.sv"
module CSRFile(input clk,
	       // rw
	       input 		   Bundle::ControlRegisterCommand csr_cmd,
	       output logic [31:0] csr_rdata,
	       input logic [31:0]  csr_wdata,
	       // control signals
	       // decode
	       input logic [11:0]  csr
); 
   // Control Status Register File
   //
   // This module constains registers that are used to maintain state
   // and performance information about the processor, they are addressed
   // using the CSR instructions.
   //
   // For now we only implement one dummy register unrelated to the RISCV
   // specification
   logic 			   csr_write;
        
   always_comb begin
      case (csr_cmd)
	Bundle::CSR_N: begin
	   csr_write = 1'b0;	   
	end	
	Bundle::CSR_W: begin
	   csr_write = 1'b1;	   
	end
	Bundle::CSR_S: begin
	   csr_write = 1'b1;	   
	end
	Bundle::CSR_I: begin
	   csr_write = 1'b1;	   
	end
	Bundle::CSR_C: begin
	   csr_write = 1'b1;	   
	end
	default: begin
	   csr_write = 1'bx;	   
	end
      endcase
   end // always_comb

   RegisterWE #(.width(32)) test_reg(.clk(clk), .wen(csr_write && csr == 12'hf), .in(csr_wdata), .out(csr_rdata));   
endmodule
