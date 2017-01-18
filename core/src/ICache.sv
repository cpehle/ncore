module ICache #(paramter int nSets, parameter int nWays)
(
              ICacheReq.client req,
              ICacheResp.server resp,
              input logic invalidate,
              input logic s1_miss;
              input logic s2_miss;
              UncachedLinkIO.client mem
);
   typedef enum {
         Ready,
         Request,
         RefillWait,
         Refill
         } State;

   // Registers
   State s,sn;
   logic invalidated, invalidated_next;
   logic refill_addr, refill_addr_next;
   logic [nSets-1:0][nWays-1:0] vb_array, vb_array_next;
   logic                   s1_valid, s1_valid_next;
   logic                   s1_vaddr, s1_vaddr_next;
   logic                   s1_tag = s1_paddr[];
   logic                   s0_valid = req.valid || s1_valid && stall;
   logic                   s0_vaddr = s1_valid && stall ? s1_vaddr : req.bits.addr;



   logic [nWays-1:0]       tag_match;
   logic [nWays-1:0]       tag_hit;

   // Data Path
   always_comb begin
      for (int i = 0; i < nWays; i++) begin
         s1_vb = !invalidate && vb_array[i][s1_vaddr[untagBits-1:0]];


      end
   end


   // Contolling State Machine
   always_comb begin
      sn = s;
      case (s)
        Ready: begin
           if (s1_miss) begin
              sn = Request;
           end
        end
        Request: begin
           if (mem.acquire.ready) begin
              sn = RefillWait;
           end
           if (s2_kill) begin
              sn = Ready;
           end
        end
        RefillWait: begin
           if (mem.grant.valid) begin
              sn = Refill;
           end
        end
        Refill: begin
           if (refill_done) begin
              sn = Ready;
           end
        end
        default:
          sn = 4'bx;
      endcase
   end
   always_ff @(posedge clk) begin
      s <= sn;
   end

   // Output
   assign mem.aquire.valid = (s == Request) && !(s2_kill)
   assign mem.aquire.bita = refill_addr >> blockOfBits;
endmodule
