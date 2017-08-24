`include "Bundle.sv"
module CSRFile(input clk,
	       // rw
	       input		   Bundle::ControlRegisterCommand cmd,
	       output logic [31:0] rdata,
	       input logic [31:0]  wdata,
	       // control signals
	       output logic	   csr_stall,
	       output logic	   eret,
	       output logic	   single_step,
	       // decode
	       input logic [11:0]  csr,
	       output logic	   read_illegal,
	       output logic	   write_illegal,
	       output logic	   system_illegal,
	       //
	       output		   Bundle::MStatus status,
	       output logic [31:0] evec,
	       input logic	   exception,
	       input logic	   retire,
	       input logic [31:0]  pc,
	       output logic [31:0] current_time
);
   Bundle::MStatus mstatus, mstatusn;
   always_ff @(posedge clk) begin
      mstatus <= mstatusn;
   end

   




endmodule
