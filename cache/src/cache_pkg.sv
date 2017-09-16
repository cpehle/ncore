/* verilator lint_off DECLFILENAME */
`ifndef _cache
`define _cache
package cache;
   parameter int tag_size = 18;
   
   typedef struct packed {
      logic 	  valid;
      logic 	  dirty;
      logic [tag_size-1:0] tag;
   } cache_tag_t;

   typedef struct packed {
      logic [9:0]   index;
      logic 	    we;
   } cache_req_t;

   typedef logic [127:0] cache_data_t;
   
   typedef struct packed {
      logic [31:0] addr;
      logic [31:0] data;
      logic 	   rw;
      logic 	   valid;
   } cpu_req_t;

   typedef struct packed {
      logic [31:0] data;
      logic 	   ready;
   } cpu_resp_t;

   typedef struct packed {
      logic [31:0]  addr; 
      logic [127:0] data; 
      logic rw;
      logic valid;
   } mem_req_t;

   typedef struct packed {
      cache_data_t data;
      logic 	  ready;
   } mem_resp_t;
endpackage // cache
`endif
/* verilator lint_on DECLFILENAME */
