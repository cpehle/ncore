///@file ReplayBuffer.sv
///@author Christian Pehle
///@brief This module implements a replay buffer for
///       a packet based communication interface
`include "Mesh.sv"

module ReplayBuffer  #(parameter int buffer_size = 16, parameter int packet_width = 64) (input clk, input nreset, output Mesh::ReplayBufferOut replay_out, input Mesh::ReplayBufferIn replay_in);

   typedef struct packed {
      logic [$clog2(buffer_size)-1:0] head;
      logic [$clog2(buffer_size)-1:0] current;
      logic [$clog2(buffer_size)-1:0] tail;
   } ReplayState;

   ReplayState s, sn;
   ReplayState is = '{'0,'0,'0};

   logic [packet_width-1:0]           buffer[0:buffer_size-1];
   logic [packet_width-1:0]           buffern[0:buffer_size-1];
   logic                              replay_buffer_full;

   assign replay_buffer_full = (s.tail == (s.head + 1));

   always_comb begin
      buffern = buffer;
      if (replay_in.packet_valid && !replay_buffer_full) begin
         buffern[s.head] = replay_in.packet;
      end
   end

   always_comb begin
      sn = s;
      if (replay_in.ready) begin
         if (s.head == s.current) begin
            replay_out.enq = 1'b0;
         end else begin
            sn.current = s.current + 1;
            replay_out.enq = 1'b1;
         end
      end

      if (replay_in.ack) begin
         sn.tail = s.tail + replay_in.ack_count;
      end

      if (replay_in.nack) begin
         sn.current = s.tail;
      end

      if (replay_in.packet_valid) begin
         sn.head = s.head + 1;
      end
   end

   always_ff @(posedge clk) begin
      if (nreset) begin
         s <= sn;
         buffer <= buffern;
      end else begin
         s <= is;
         for (int i = 0; i < buffer_size; i++) begin
            buffer[i] <= '0;
         end
      end
   end

   assign replay_out.ready = !replay_buffer_full;
   assign replay_out.packet = buffer[s.current];
endmodule
