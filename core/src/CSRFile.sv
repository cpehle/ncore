`include "Bundle.sv"
module CSRFile(input clk,
	       // rw
	       input		   Bundle::ControlRegisterCommand cmd,
	       output logic [31:0] rdata,
	       input logic [31:0]  wdata,
	       // control signals
	       output logic	   csr_stall,
	       output logic	   eret,
	       output logic	   single_step,
	       // decode
	       input logic [11:0]  csr,
	       output logic	   read_illegal,
	       output logic	   write_illegal,
	       output logic	   system_illegal,
	       //
	       output		   Bundle::MStatus status,
	       output logic [31:0] evec,
	       input logic	   exception,
	       input logic	   retire,
	       input logic [31:0]  pc,
	       output logic [31:0] current_time
); 
   // Control Status Register File
   //
   // This module constains registers that are used to maintain state
   // and performance information about the processor, they are addressed
   // using the CSR instructions.

   
   
   Register#(.width($bits(Bundle::MStatus))) reg_mstatus();
   Register#(.width(32)) reg_mepc();
   Register#(.width(32)) reg_mcause() ;
   Register#(.width(32)) reg_mtval();
   Register#(.width(32)) reg_mscratch();   
   Register#(.width(32)) reg_mtimecmp();   
   Register#(.width(32)) reg_medeleg();   
   Register#(.width($bits(Bundle::MIP))) reg_mip();
   Register#(.width($bits(Bundle::MIP))) reg_mie();   
   Register#(.width(1)) reg_wfi();   
   Register#(.width(32)) reg_mtvec();   
   // Counter reg_time();
   // Counter reg_instret();
   Register reg_mcounteren();

   Register reg_debug();
   Register reg_dpc();   
   Register reg_dscratch();   
   Register reg_single_stepped();
   Register reg_dcsr();


/*     
  val mstatus = 0x300
  val misa = 0x301
  val medeleg = 0x302
  val mideleg = 0x303
  val mie = 0x304
  val mtvec = 0x305
  val mscratch = 0x340
  val mcounteren = 0x306
  val mepc = 0x341
  val mcause = 0x342
  val mtval = 0x343
  val mip = 0x344
  val tselect = 0x7a0
  val tdata1 = 0x7a1
  val tdata2 = 0x7a2
  val tdata3 = 0x7a3
  val dcsr = 0x7b0
  val dpc = 0x7b1
  val dscratch = 0x7b2
  val mcycle = 0xb00
  val minstret = 0xb02
*/
   

   assign status = 33'h0;
   


endmodule
