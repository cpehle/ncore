/// @file Router.sv
/// @author Christian Pehle
/// @brief This implements a static nort/south, east/west router with round robin arbitration
`include "Mesh.sv"
module Router #(parameter int x = 0, parameter int y = 0) (
              input  clk,
              input  Mesh::RouterIn s_out,
              output Mesh::RouterOut s_in,
              input  Mesh::RouterIn w_out,
              output Mesh::RouterOut w_in,
              input  Mesh::RouterIn n_out,
              output Mesh::RouterOut n_in,
              input  Mesh::RouterIn e_out,
              output Mesh::RouterOut e_in,
              input  Mesh::RouterIn c_out,
              output Mesh::RouterOut c_in
);
   RouterInput south(.packet_in(s_out.packet),
                     .packet_out(s_in.packet),
                     .ready     (s_in.ready),
                     /*AUTOINST*/
                     // Interfaces
                     // Outputs
                     .request           (request),
                     // Inputs
                     .clk               (clk),
                     .valid             (valid),
                     .grant             (grant));

   RouterInput west(/*AUTOINST*/
                    // Interfaces
                    .packet_in          (packet_in),
                    .packet_out         (packet_out),
                    // Outputs
                    .ready              (ready),
                    .request            (request),
                    // Inputs
                    .clk                (clk),
                    .valid              (valid),
                    .grant              (grant));


   RouterInput north(/*AUTOINST*/
                     // Interfaces
                     .packet_in         (packet_in),
                     .packet_out        (packet_out),
                     // Outputs
                     .ready             (ready),
                     .request           (request),
                     // Inputs
                     .clk               (clk),
                     .valid             (valid),
                     .grant             (grant));

   RouterInput east(/*AUTOINST*/
                    // Interfaces
                    .packet_in          (packet_in),
                    .packet_out         (packet_out),
                    // Outputs
                    .ready              (ready),
                    .request            (request),
                    // Inputs
                    .clk                (clk),
                    .valid              (valid),
                    .grant              (grant));

   RouterInput core(/*AUTOINST*/
                    // Interfaces
                    .packet_in          (packet_in),
                    .packet_out         (packet_out),
                    // Outputs
                    .ready              (ready),
                    .request            (request),
                    // Inputs
                    .clk                (clk),
                    .valid              (valid),
                    .grant              (grant));

   RRArbiter arbiter();
   RouterOutput out();
endmodule
