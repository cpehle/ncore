module tag_memory_cache_sim(
			    input logic clk,
			    input 	cache::cache_req_t tag_req, 
			    input 	cache::cache_tag_t tag_write,
			    output 	cache::cache_tag_t tag_read
);
   parameter size = 1024;   
   cache::cache_tag_t tag_mem[0:size-1];
   
   initial begin
      for (int i=0; i < size; i++) begin
	tag_mem[i] = '0;
      end
   end

   assign tag_read = tag_mem[tag_req.index];
   
   always_ff @(posedge(clk)) begin 
      if (tag_req.we) begin
	tag_mem[tag_req.index] <= tag_write;
      end
   end
endmodule
