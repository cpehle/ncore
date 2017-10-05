module Mux5(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in4, in3, in2, in1, in0, sel4, sel3, sel2, sel1, sel0
   );
   parameter N = 32;

   input [N-1:0] in4;
   input [N-1:0] in3;
   input [N-1:0] in2;
   input [N-1:0] in1;
   input [N-1:0] in0;

   input 	  sel4;   
   input          sel3;
   input          sel2;
   input          sel1;
   input          sel0;

   output [N-1:0] out;

   assign out[N-1:0] = ({(N){sel0}}  & in0[N-1:0] |
			 {(N){sel1}}  & in1[N-1:0] |
			 {(N){sel2}}  & in2[N-1:0] |
			 {(N){sel3}}  & in3[N-1:0] |
                         {(N){sel4}}  & in4[N-1:0]);
endmodule
