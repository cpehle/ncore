///@file RouterInput.sv
///@author Christian Pehle
///@brief Input to the mesh router
`include "Mesh.sv"
module RouterInput(input clk,
                   // Packet input
                   input        Mesh::Packet packet_in,
                   input logic  valid,
                   output logic ready,
                   // Packet out
                   output       Mesh::Packet packet_out,
                   output logic request,
                   input logic  grant
                   );
   typedef enum {PACKET_PENDING, READY} State;

   State s, sn;
   Mesh::Packet p, pn;

   always_comb begin
      // default assignments
      sn = s;
      pn = p;
      if (s == PACKET_PENDING) begin
         if (grant) begin
            sn = READY;
         end
      end else begin
         if (valid) begin
            pn = packet_in;
            sn = PACKET_PENDING;
         end
      end
   end

   always_ff @(posedge clk) begin
      s <= sn;
      p <= pn;
   end

   assign packet_out = p;
   assign ready = (s == PACKET_PENDING) ? 1'b0 : 1'b1;
   assign request = (s == PACKET_PENDING) ? 1'b0 : 1'b1;
endmodule
