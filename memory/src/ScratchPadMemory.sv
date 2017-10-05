`include "../../core/src/Bundle.sv"
module ScratchPadMemory(input clk,
			input  Bundle::MemoryIn req[5],
			output Bundle::MemoryOut resp[5]
);
   // This module implements a four bank scratch pad memory, 
   // each memory bank can be accessed from five different   
   // sources.
   //
   //

   
   // request path
   logic [4:0] 		       grant0;
   logic [4:0] 		       grant0_1;
   logic 		       out0_valid;   
   Bundle::MemoryRequest out0;
   Bundle::MemoryOut resp0;
   
   PriorityArbiter#(.N(5)) arb0(.request({req[0].req_valid && req[0].req.addr[3:2] == 2'h0,
					  req[1].req_valid && req[1].req.addr[3:2] == 2'h0,
					  req[2].req_valid && req[2].req.addr[3:2] == 2'h0,
					  req[3].req_valid && req[3].req.addr[3:2] == 2'h0,
					  req[4].req_valid && req[4].req.addr[3:2] == 2'h0
					  }),
				.grant(grant0)
				);

   Mux5#(.N($bits(Bundle::MemoryRequest))) mux0(.sel0(grant0[0]),
						.sel1(grant0[1]),
						.sel2(grant0[2]),
						.sel3(grant0[3]),
						.sel4(grant0[4]),
						.in0(req[0].req),
						.in1(req[1].req),
						.in2(req[2].req),
						.in3(req[3].req),
						.in4(req[4].req),
						.out(out0)
						);
   assign out0_valid = |grant0;   
   MemoryBank m0(.clk(clk), 
		 .request('{out0, out0_valid, grant0}), 
		 .response('{resp0, grant0_1}));
   
   logic [4:0] grant1;
   logic [4:0] grant1_1;
   Bundle::MemoryRequest out1;
   logic       out1_valid;   
   Bundle::MemoryOut resp1;
   PriorityArbiter#(.N(5)) arb1(.request({req[0].req_valid && req[0].req.addr[3:2] == 2'h1,
					 req[1].req_valid && req[1].req.addr[3:2] == 2'h1,
					 req[2].req_valid && req[2].req.addr[3:2] == 2'h1,
					 req[3].req_valid && req[3].req.addr[3:2] == 2'h1,
					 req[4].req_valid && req[4].req.addr[3:2] == 2'h1
					}),
			       .grant(grant1));
   Mux5#(.N($bits(Bundle::MemoryRequest)))  mux1(.sel0(grant1[0]),
						 .sel1(grant1[1]),
						 .sel2(grant1[2]),
						 .sel3(grant1[3]),
						 .sel4(grant1[4]),
						 .in0(req[0].req),
						 .in1(req[1].req),
						 .in2(req[2].req),
						 .in3(req[3].req),
						 .in4(req[4].req),
						 .out(out1)
						 );
   
   assign out1_valid = |grant1;   
   MemoryBank m1(.clk(clk), 
		 .request('{out1, out1_valid, grant1}), 
		 .response('{resp1, grant1_1}));

   logic [4:0] grant2;
   logic [4:0] grant2_1;
   Bundle::MemoryRequest out2;
   logic       out2_valid;   
   Bundle::MemoryOut resp2;
   PriorityArbiter#(.N(5)) arb2(.request({req[0].req_valid && req[0].req.addr[3:2] == 2'h2,
					 req[1].req_valid && req[1].req.addr[3:2] == 2'h2,
					 req[2].req_valid && req[2].req.addr[3:2] == 2'h2,
					 req[3].req_valid && req[3].req.addr[3:2] == 2'h2,
					 req[4].req_valid && req[4].req.addr[3:2] == 2'h2
					}),
			       .grant(grant2));

   Mux5#(.N($bits(Bundle::MemoryRequest)))  mux2(.sel0(grant2[0]),
						       .sel1(grant2[1]),
						       .sel2(grant2[2]),
						       .sel3(grant2[3]),
						       .sel4(grant2[4]),
						       .in0(req[0].req),
						       .in1(req[1].req),
						       .in2(req[2].req),
						       .in3(req[3].req),
						       .in4(req[4].req),
						       .out(out2)
						       );
   assign out2_valid = |grant2;
   MemoryBank m2(.clk(clk),
		 .request('{out2, out2_valid, grant2}), 
		 .response('{resp2, grant2_1}));


   logic [4:0] grant3;
   logic [4:0] grant3_1;
   Bundle::MemoryRequest out3;
   logic       out3_valid;   
   Bundle::MemoryOut resp3;
   PriorityArbiter#(.N(5)) arb3(.request({req[0].req_valid && req[0].req.addr[3:2] == 2'h3,
					 req[1].req_valid && req[1].req.addr[3:2] == 2'h3,
					 req[2].req_valid && req[2].req.addr[3:2] == 2'h3,
					 req[3].req_valid && req[3].req.addr[3:2] == 2'h3,
					 req[4].req_valid && req[4].req.addr[3:2] == 2'h3
					}),
			       .grant(grant3));

   Mux5#(.N($bits(Bundle::MemoryRequest)))  mux3(.sel0(grant3[0]),
						 .sel1(grant3[1]),
						 .sel2(grant3[2]),
						 .sel3(grant3[3]),
						 .sel4(grant3[4]),
						 .in0(req[0].req),
						 .in1(req[1].req),
						 .in2(req[2].req),
						 .in3(req[3].req),
						 .in4(req[4].req),
						 .out(out3)
						 );
   
   assign out3_valid = |grant3;   
   MemoryBank m3(.clk(clk), 
		 .request('{out3, out3_valid, grant3}), 
		 .response('{resp3, grant3_1}));
   
   logic [4:0] grant_io;
   logic [4:0] grant_io_1;
   Bundle::MemoryRequest out_io;
   Bundle::MemoryOut out_io_req;   
   logic       out_io_valid;
   Bundle::MemoryOut resp_io;   
   PriorityArbiter#(.N(5)) arb_io(.request({req[0].req_valid && req[0].req.addr[3:2] == 2'h4,
					   req[1].req_valid && req[1].req.addr[3:2] == 2'h4,
					   req[2].req_valid && req[2].req.addr[3:2] == 2'h4,
					   req[3].req_valid && req[3].req.addr[3:2] == 2'h4,
					   req[4].req_valid && req[4].req.addr[3:2] == 2'h4
					}),
			       .grant(grant_io));

   Mux5#(.N($bits(Bundle::MemoryRequest)))  mux_io(.sel0(grant_io[0]),
						   .sel1(grant_io[1]),
						   .sel2(grant_io[2]),
						   .sel3(grant_io[3]),
						   .sel4(grant_io[4]),
						   .in0(req[0].req),
						   .in1(req[1].req),
						   .in2(req[2].req),
						   .in3(req[3].req),
						   .in4(req[4].req),
						   .out(out_io)
						   );
   
   // response path
   logic [4:0] resp_grant0;   
   PriorityArbiter #(.N(5)) resp_arb0(.request({grant0_1[0],
						grant1_1[0],
						grant2_1[0],
						grant3_1[0]
						}),
				      .grant(resp_grant0)
				      );
   
   Mux5 resp_mux0(.sel0(resp_grant0[0]),
		  .sel1(resp_grant0[1]),
		  .sel2(resp_grant0[2]),
		  .sel3(resp_grant0[3]),
		  .sel4(resp_grant0[4]),
		  .in0(req[0].req),
		  .in1(req[1].req),
		  .in2(req[2].req),
		  .in3(req[3].req),
		  .in4(req[4].req),		  
		  .out(resp[0]));

   PriorityArbiter resp_arb1(.request(),
			     .grant());   
   Mux5 resp_mux1(
			 .out(resp[0]));

   PriorityArbiter resp_arb2(.request(),
			     .grant());   
   Mux5 resp_mux2(
			 .out(resp[0]));

   PriorityArbiter resp_arb3(.request(),
			     .grant());   
   Mux5 resp_mux3(
			 .out(resp[0]));     
endmodule
