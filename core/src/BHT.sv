module BHT(
           input logic [31:0] addr,
           input logic update
   );
   parameter  int bht_size = 16;
   localparam int bht_bits = $clog2(bht_size);
   logic [1:0]   bht[0:bht_size-1];
   logic [1:0]   bhtn[0:bht_size-1];
   logic         history[bht_bits-1:0];
   logic         historyn[bht_bits-1:0];

   typedef struct packed {
      logic [31:0] value;
   } result_t;

   logic           taken;
   result_t res;


   always_comb begin
      history[bht_bits-1:0] = '0;
      taken = res.value[0];
      historyn[bht_bits-1:0] = update ? '{taken, history[bht_bits-1:1]} : history[bht_bits-1:0];

   end
endmodule
