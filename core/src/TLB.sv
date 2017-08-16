// file: TLB
//
// Translation Lookaside Buffer
module TLB();


   typedef struct packed {
      logic []    ppn;
      logic []    tag;
      logic []    level;
      logic       u;
      logic       g;
      logic       ae;
      logic       sw;
      logic       sx;
      logic       sr;
      logic       pw;
      logic       px;
      logic       pr;
      logic       c;
   } Entry;

   enum {
         TLB_READY,
         TLB_REQUEST,
         TLB_WAIT,
         TLB_WAIT_INVALIDATE
   } State;

   ///< state register
   State s, sn;




endmodule
