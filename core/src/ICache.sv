module ICache();
// Connection to Memory
// Connection to Core

   typedef enum {
         ready,
         request,
         refill_wait,
         refill
         } State;

   State s,sn;
   logic        s1_miss;



   always_comb begin
      sn = s;
      case (s)
        ready: begin
           if (s1_miss) begin
              sn = request;
           end
        end
        request: begin
           if (io.mem.acquire.ready) begin
              sn = refill_wait;
           end
           if (io.s2_kill) begin
              sn = ready;
           end
        end
        refill_wait: begin
           if (io.mem.grant.valid) begin
              sn = refill;
           end
        end
        refill: begin
           if (refill_done) begin
              sn = ready;
           end
        end
      endcase
   end
   always_ff @(posedge clk) begin
      s <= sn;
   end
endmodule
