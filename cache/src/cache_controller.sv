module cache_controller(
			input logic clk,
			input logic reset,
			input	    cache::cpu_req_t cpu_req,
			input	    cache::mem_resp_t mem_data,
			output	    cache::mem_req_t mem_req,
			output	    cache::cpu_resp_t cpu_resp
);
   // This module implements a direct mapped cache with cache lines
   // of 128 Bit = 16 Byte width.
   //
   //  31 14 | 13  4 | 3   2 | 1   0
   //  +----------------------------+
   //  | tag | index | block | byte |
   //  +----------------------------+
   //
   // It is backed by a single port memory of the same width.
   //
   // The width of index, determines the overall size of the cache memory
   //
   // width(index) * 128 = memory_size
   //
   // Since memory compilers don't produce parametrized modules, we need
   // to be content with the size that they offer us, so there is no point to
   // parametrize the cache controller module itself.
   //
   // The diagram above explains how an address coming from the cpu is divided
   // into parts
   //
   // "tag" refers to the part of the address that is used to determine
   //       whether an entry in the cache memory is the same as the one
   //       requested by the processor. There is a separate tag memory
   //       which stores those, it has the same number of entries as the
   //       cache memory.
   // "index" refers to the part of the address that is used to index
   //         into both the cache and tag memory, it therefore has to
   //         be log_2(num_entries) bit wide.
   // "block" indexes into the entries of one cache line by word, so in the
   //         current implementation it has to be log_{4}(16) = 2 bit wide.
   // "byte" indexes into one word, so it has to be 2 bit wide.
   //
   // There are a number of things that are not implemented yet.
   //
   // TODO:
   //
   // - Need to figure out an elegant way to do partial reads/writes of individual words
   //   the memory macro supports that, but we need to investigate it further.
   // - It would be nice if the vector unit would be able to get full width access to
   //   to one cache line, this can be easily implemented in principle but needs some
   //   work on the vector unit side.
   // - Omnibus access has not been implemented yet.
   // - The memory modules are simulation models so far, we need to get the appropriate
   //   TSMC macros
   // - Maybe investigate a quad port cache memory
   //

   /* verilator lint_off UNUSED */
   function logic[1:0] cache_block(cache::cpu_req_t req);      
      return req.addr[3:2];
   endfunction // cache_block
   /* verilator lint_on UNUSED */

   /* verilator lint_off UNUSED */
   function logic[9:0] cache_index(cache::cpu_req_t req);      
      return req.addr[13:4];
   endfunction // cache_index
   /* verilator lint_on UNUSED */

   function logic[17:0] cache_tag(cache::cpu_req_t req);      
      return req.addr[31:14];
   endfunction

   function logic[13:0] cache_entry(cache::cpu_req_t req);      
      // TODO(Christian): Slightly misleading
      return req.addr[13:0];
   endfunction

   typedef enum			    {idle, compare_tag, allocate, write_back} state_t;

   // fsm state
   state_t state, next_state;

   // internal wires
   cache::cache_tag_t tag_read;
   cache::cache_tag_t tag_write;
   cache::cache_req_t tag_req;
   cache::cache_data_t data_read, data_write;
   cache::cache_req_t data_req;

   // outputs
   cache::cpu_resp_t cpu_resp_v;
   cache::mem_req_t mem_req_v;

   // cache controller finite state machine
   always_comb begin
      // default assignments
      next_state = state;
      cpu_resp_v = '{0,0};
      tag_req.we = '0;
      tag_req.index = cache_index(cpu_req);
      data_req.we = '0;
      data_req.index = cache_index(cpu_req);
      data_write = data_read;

      case(cache_block(cpu_req))
	2'b00:data_write[31:0] = cpu_req.data;
	2'b01:data_write[63:32] = cpu_req.data;
	2'b10:data_write[95:64] = cpu_req.data;
	2'b11:data_write[127:96] = cpu_req.data;
      endcase
      case(cache_block(cpu_req))
	2'b00: cpu_resp_v.data = data_read[31:0];
	2'b01: cpu_resp_v.data = data_read[63:32];
	2'b10: cpu_resp_v.data = data_read[95:64];
	2'b11: cpu_resp_v.data = data_read[127:96];
      endcase

      mem_req.addr = cpu_req.addr;
      mem_req.data = data_read;
      mem_req.rw = '0;

      case (state)
	idle: begin
	   if (cpu_req.valid) begin
	     next_state = compare_tag;
	   end
	end
	compare_tag: begin
	   if (cache_tag(cpu_req) == tag_read.tag && tag_read.valid) begin
	      // cache hit
	      cpu_resp_v.ready = '1;
	      if (cpu_req.rw) begin
		 tag_req.we = '1;
		 data_req.we = '1;
		 tag_write.tag = tag_read.tag;
		 tag_write.valid = '1;
		 tag_write.dirty = '1;
	      end
	      next_state = idle;
	   end else begin
	      // cache miss
	      tag_req.we = '1;
	      tag_write.valid = '1;
	      tag_write.tag = cache_tag(cpu_req);
	      tag_write.dirty = cpu_req.rw;
	      mem_req_v.valid = '1;
	      if (tag_read.valid == 1'b0 || tag_read.dirty == 1'b0) begin
		 next_state = allocate;
	      end else begin
		 mem_req_v.addr = {tag_read.tag, cache_entry(cpu_req)};
		 mem_req_v.rw = '1;
		 next_state = write_back;
	      end
	   end // else: !if(cache_tag(cpu_req) == tag_read.tag && tag_read.valid)
	end
	allocate: begin
	   // wait until a new cache line is allocated
	   if (mem_data.ready) begin
	      next_state = compare_tag;
	      data_write = mem_data.data;
	      data_req.we = '1;
	   end
	end
	write_back: begin
	   // wait until dirty cache line is written back
	   if (mem_data.ready) begin
	      mem_req_v.valid = '1;
	      mem_req_v.rw = '0;
	      next_state = allocate;
	   end
	end
      endcase
   end

   always_ff @(posedge clk) begin
      if (reset) begin
	 state <= idle;
      end else begin
	 state <= next_state;
      end
   end

   data_memory_cache_sim dm(.clk, .data_req, .data_write, .data_read);
   tag_memory_cache_sim tm(.clk, .tag_req, .tag_write, .tag_read);

   assign cpu_resp = cpu_resp_v;
   assign mem_req = mem_req_v;
endmodule
