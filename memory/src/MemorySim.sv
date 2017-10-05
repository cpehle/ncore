module MemorySim(
		 input logic 	     clk,
		 input logic [31:0]  data_req,
		 input logic [1:0]   data_req_typ,
		 input logic [31:0]  rr_address,
		 output logic [31:0] rr_data
);   
   parameter size = 1024;   
   logic [31:0] data_mem[0:size-1];
   
      
   initial begin
      for (int i=0; i < size; i++) begin
	 data_mem[i] = '0;
      end
   end

   
   assign data_read = result;
      
   always_ff @(posedge(clk)) begin
      result <= data_mem[data_req.index];
      if (data_req.we) begin
	 data_mem[data_req.index] <= data_write;	 
      end
   end
endmodule
