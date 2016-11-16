`ifndef _Mesh
`define _Mesh
package Mesh;
   typedef struct packed {
      logic [14:0] x;
      logic [14:0] y;
      logic [33:0] address;
   } Address;

   typedef struct packed {
      Address address;
      Address req_address;
   } ReadPacket;

   typedef struct packed {
      Address address;
      logic [63:0] data;
   } WritePacket;

   typedef union packed {
      ReadPacket read;
      WritePacket write;
   } Packet;

   typedef struct packed {
      logic      valid;
      logic      ready;
      Packet     packet;
   } RouterIn;

   typedef struct packed {
      logic       valid;
      logic       ready;
      Packet packet;
   } RouterOut;

   typedef struct packed {
      logic [63:0] packet;
      logic        packet_valid;
      logic        ready;
      logic        ack;
      logic [3:0]  ack_count;
      logic        nack;
   } ReplayBufferIn;

   typedef struct packed {
      logic [63:0] packet;
      logic        enq;
      logic        ready;
   } ReplayBufferOut;
endpackage
`endif
