`include "Bundle.sv"
module CSRFile(input clk,
	       // rw
	       input 		   Bundle::ControlRegisterCommand csr_cmd,
	       output logic [31:0] csr_rdata,
	       input logic [31:0]  csr_wdata,
	       // control signals
	       output logic 	   csr_stall,
	       // decode
	       input logic [11:0]  csr,
	       output logic 	   csr_read_illegal,
	       output logic 	   csr_write_illegal,
	       output logic 	   csr_system_illegal
	       // output logic [31:0] current_time
	       // input logic [31:0]  pc

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
   
   assign csr_read_illegal = 1'b0;
   assign csr_write_illegal = 1'b0;
   assign csr_system_illegal = 1'b0;
   assign csr_stall = 1'b0;   
endmodule
