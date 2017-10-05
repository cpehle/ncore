/// @file DataPath.sv
/// @author Christian Pehle
/// @brief This module implements a five stage fixed point pipeline
/// with bypassing.
`include "Bundle.sv"
module DataPath(
		input  clk,
		input  reset,
		input  Bundle::ControlToData ctl, ///< Control signals from control to data path
		output Bundle::DataToControl dat, ///< Signals from data path to control
		output Bundle::MemoryIn imem_in, ///< Signals to instruction memory
		input  Bundle::MemoryOut imem_out, ///< Signals from instruction memory
		output Bundle::MemoryIn dmem_in, ///< Signals to data memory
		input  Bundle::MemoryOut dmem_out  ///< Signals from data memory
   );

   /// The following are type declarations of pipeline registers
   /// There are 5 pipeline stages

   typedef struct packed {
      logic [31:0] pc; // program counter
   } InstructionFetchState;

   typedef struct packed {
      logic [31:0] pc;   // program  counter
      logic [31:0] inst; // instruction
   } InstructionDecodeState;

   typedef struct packed {
      logic [31:0]              pc;           // program counter
      logic [31:0]              inst;         // instruction
      logic [4:0]               wb_addr;      // write back address
      logic [4:0]               rs1_addr;     // address of source register 1
      logic [4:0]               rs2_addr;     // address of source register 2
      logic [31:0]              op1_data;     // operand 1 data
      logic [31:0]              op2_data;     // operand 2 data
      logic [31:0]              rs2_data;     // source register 2 data
      Bundle::BranchType        ctrl_br_type; // control branch type
      Bundle::Op2Sel            ctrl_op2_sel; // control operand 2 select
      Bundle::AluFun            ctrl_alu_fun; // control alu function
      Bundle::WriteBackSelect   ctrl_wb_sel;  // control writeback select
      logic                     ctrl_rf_wen;  // control register file write enable
      logic                     ctrl_mem_val; // control memory value
      Bundle::MemoryWriteSignal ctrl_mem_fcn; // control memory function
      Bundle::MemoryMaskType    ctrl_mem_typ; // control memory type
      Bundle::ControlRegisterCommand  ctrl_csr_cmd; // control condition state register command
   } ExecuteState;

   typedef struct packed {
      logic [31:0]              pc;           // program counter
      logic [31:0]              inst;         // instruction
      logic [31:0]              alu_out;      // alu out
      logic [4:0]               wb_addr;      // write back address
      logic [4:0]               rs1_addr;     // address of source register 1
      logic [4:0]               rs2_addr;     // address of source register 2
      logic [31:0]              op1_data;     // operand 1 data
      logic [31:0]              op2_data;     // operand 2 data
      logic [31:0]              rs2_data;     // source register 2 data
      logic                     ctrl_rf_wen;  // control register file write enable
      logic                     ctrl_mem_val; // control memory value
      Bundle::MemoryWriteSignal ctrl_mem_fcn; // control memory function
      Bundle::MemoryMaskType    ctrl_mem_typ; // control memory type
      Bundle::WriteBackSelect   ctrl_wb_sel;  // control writeback select
      Bundle::ControlRegisterCommand ctrl_csr_cmd; // control condition state register command
   } MemoryState;

   typedef struct packed {
      logic [4:0]  wb_addr;     // writeback address
      logic [31:0] wb_data;     // writeback data
      logic        ctrl_rf_wen; // control register file write enable
   } WriteBackState;

   // These structures capture the whole state of
   // the fixed point pipeline
   InstructionFetchState  ifs, ifsn;
   InstructionDecodeState ids, idsn;
   ExecuteState           es, esn;
   MemoryState            ms, msn;
   WriteBackState         wbs, wbsn;

   logic [4:0]    dec_rs1_addr;
   logic [4:0]    dec_rs2_addr;
   logic [31:0]   exe_brjmp_target;
   logic [31:0]   exe_jump_reg_target;
   logic [31:0]   exception_target;
   logic [31:0]   if_instruction;
   logic [4:0]    dec_wb_addr;
   logic [31:0]   dec_alu_op2;
   logic [31:0]   dec_op1_data;
   logic [31:0]   dec_op2_data;
   logic [31:0]   dec_rs2_data;
   logic [31:0]   mem_wb_data;

   // CSR wires
   logic 	  csr_write_illegal;
   logic 	  csr_system_illegal;
   logic 	  csr_read_illegal;
   logic 	  csr_stall;
   logic [31:0]   csr_rdata;
     
   // TODO
   assign exception_target = 32'h0;
     
   /// Instruction Fetch stage
   always_comb begin
      // default assignment
      ifsn = ifs;
      if ((!ctl.dec_stall && !ctl.cmiss_stall) || ctl.pipeline_kill) begin
	 ifsn.pc = (ctl.exe_pc_sel == Bundle::PC_4) ? ifs.pc + 32'd4 :
		   (ctl.exe_pc_sel == Bundle::PC_BRJMP) ? exe_brjmp_target :
		   (ctl.exe_pc_sel == Bundle::PC_JALR) ? exe_jump_reg_target :
		   exception_target;
      end
   end
   always_ff @(posedge clk) begin
      if (reset) begin
	 ifs <= '0;
      end else begin
	 ifs <= ifsn;
      end
   end

   assign imem_in.req.addr = ifs.pc;
   assign imem_in.req_valid = 1'b1;
   assign if_instruction = imem_out.res.data;

   /// Instruction Decode Stage
   always_comb begin
      idsn = ids;
      if (ctl.pipeline_kill) begin
	 idsn.inst = Bundle::Bubble;
      end else if (!ctl.dec_stall && !ctl.cmiss_stall) begin
	 if (ctl.if_kill) begin
	    idsn.inst = Bundle::Bubble;
	 end else begin
	    idsn.inst = if_instruction;
	 end
	 idsn.pc = ifs.pc;
      end
   end // always_comb
   always_ff @(posedge clk) begin
      ids <= idsn;
   end

   /// decode the register addresses
   assign dec_rs2_addr[4:0] = ids.inst[24:20];
   assign dec_rs1_addr[4:0] = ids.inst[19:15];
   assign dec_wb_addr[4:0] = ids.inst[11:7];

   /// Register File
   /// Register File I/O
   Bundle::RegisterFileOut rf_out;
   Bundle::RegisterFileIn rf_in;
   always_comb begin
      rf_in.rs1_addr = dec_rs1_addr;
      rf_in.rs2_addr = dec_rs2_addr;
      rf_in.waddr = wbs.wb_addr;
      rf_in.wdata = wbs.wb_data;
      rf_in.we = wbs.ctrl_rf_wen;
   end

   RegisterFile register_file(/*AUTOINST*/
			      // Interfaces
			      .rf_in		(rf_in),
			      .rf_out		(rf_out),
			      // Inputs
			      .clk		(clk));
   
   /// Immediate Variables
   /// See section 2.2 of the riscv instruction manual
   logic [11:0] imm_itype;   
   logic [11:0] imm_stype;
   logic [11:0] imm_sbtype;
   logic [19:0] imm_utype;
   logic [19:0] imm_ujtype;
   logic [31:0] imm_z;
   logic [31:0] imm_itype_sext;  
   logic [31:0] imm_stype_sext; 
   logic [31:0] imm_sbtype_sext; 
   logic [31:0] imm_utype_sext;  
   logic [31:0] imm_ujtype_sext;
 
   always_comb begin
      imm_itype = ids.inst[31:20];
      imm_stype = {ids.inst[31:25],ids.inst[11:7]};
      imm_sbtype = {ids.inst[31],ids.inst[7],ids.inst[30:25],ids.inst[11:8]};
      imm_utype = ids.inst[31:12];
      imm_ujtype = {ids.inst[31], ids.inst[19:12], ids.inst[20], ids.inst[30:21]};
      imm_z = {27'b0,ids.inst[19:15]};
      /// Compute sign extended immediates
      imm_itype_sext = {{20{imm_itype[11]}}, imm_itype};
      imm_stype_sext = {{20{imm_stype[11]}}, imm_stype};
      imm_sbtype_sext = {{19{imm_sbtype[11]}}, imm_sbtype, 1'b0};
      imm_utype_sext = {imm_utype, 12'b0};
      imm_ujtype_sext = {{11{imm_ujtype[19]}}, imm_ujtype, 1'b0};
   end
      
   /// Operand 2 Multiplexer
   assign dec_alu_op2[31:0] = (ctl.op2_sel == Bundle::OP2_RS2)    ? rf_out.rs2_data[31:0] :
			      (ctl.op2_sel == Bundle::OP2_ITYPE)  ? imm_itype_sext[31:0] :
			      (ctl.op2_sel == Bundle::OP2_STYPE)  ? imm_stype_sext[31:0] :
			      (ctl.op2_sel == Bundle::OP2_SBTYPE) ? imm_sbtype_sext[31:0] :
			      (ctl.op2_sel == Bundle::OP2_UTYPE)  ? imm_utype_sext[31:0] :
			      (ctl.op2_sel == Bundle::OP2_UJTYPE) ? imm_ujtype_sext[31:0] :
			      32'b0;

   /// Execute stage
   
   /// Bypassing
   always_comb begin
      if (1) begin
	 // bypass multiplexers
	 // op1 multiplexer
	 dec_op1_data = (ctl.op1_sel == Bundle::OP1_IMZ) ? imm_z :
			(ctl.op1_sel == Bundle::OP1_PC) ? ids.pc :
			(es.wb_addr  == dec_rs1_addr) && (dec_rs1_addr != 0) && es.ctrl_rf_wen  ? alu_out.data :
			(ms.wb_addr  == dec_rs1_addr) && (dec_rs1_addr != 0) && ms.ctrl_rf_wen  ? mem_wb_data :
			(wbs.wb_addr == dec_rs1_addr) && (dec_rs1_addr != 0) && wbs.ctrl_rf_wen ? wbs.wb_data :
			rf_out.rs1_data;

	 // op2 multiplexer
	 dec_op2_data = (es.wb_addr  == dec_rs2_addr) && (dec_rs2_addr != 0) && es.ctrl_rf_wen  && (ctl.op2_sel == Bundle::OP2_RS2) ? alu_out.data :
			 (ms.wb_addr  == dec_rs2_addr) && (dec_rs2_addr != 0) && ms.ctrl_rf_wen  && (ctl.op2_sel == Bundle::OP2_RS2) ? mem_wb_data :
			 (wbs.wb_addr == dec_rs2_addr) && (dec_rs2_addr != 0) && wbs.ctrl_rf_wen && (ctl.op2_sel == Bundle::OP2_RS2) ? wbs.wb_data :
			 dec_alu_op2;

	 // register 2 data
	 dec_rs2_data = (es.wb_addr  == dec_rs2_addr) && es.ctrl_rf_wen  && (dec_rs2_addr != 0) ? alu_out.data :
			(ms.wb_addr  == dec_rs2_addr) && ms.ctrl_rf_wen  && (dec_rs2_addr != 0) ? mem_wb_data :
			(wbs.wb_addr == dec_rs2_addr) && wbs.ctrl_rf_wen && (dec_rs2_addr != 0) ? wbs.wb_data :
			rf_out.rs2_data;
      end else begin
	 dec_op1_data = (ctl.op1_sel == Bundle::OP1_IMZ) ? imm_z :
			(ctl.op1_sel == Bundle::OP1_PC) ? ids.pc : rf_out.rs1_data;
	 dec_rs2_data = rf_out.rs2_data;
	 dec_op2_data = dec_alu_op2;
      end
   end

   /// Execute Stage
   always_comb begin
      // default assignments
      esn = es;
      exe_brjmp_target = es.pc + es.op2_data;
      exe_jump_reg_target = alu_out.data;
      
      // stall logic
      if ((ctl.dec_stall && !ctl.cmiss_stall) || ctl.pipeline_kill) begin
	 // kill exe stage
	 esn.inst = Bundle::Bubble;
	 esn.wb_addr = 0;
	 esn.ctrl_rf_wen = 1'b0;
	 esn.ctrl_mem_val = 1'b0;
	 esn.ctrl_mem_fcn = Bundle::M_X;
	 esn.ctrl_br_type = Bundle::BR_N;
	 esn.ctrl_csr_cmd = Bundle::CSR_N;
      end else if (!ctl.dec_stall && !ctl.cmiss_stall) begin
	 esn.pc = ids.pc;
	 esn.rs1_addr = dec_rs1_addr;
	 esn.rs2_addr = dec_rs2_addr;
	 esn.op1_data = dec_op1_data;
	 esn.op2_data = dec_op2_data;
	 esn.rs2_data = dec_rs2_data;
	 esn.ctrl_op2_sel = ctl.op2_sel;
	 esn.ctrl_alu_fun = ctl.alu_fun;
	 esn.ctrl_wb_sel = ctl.wb_sel;
	 if (ctl.dec_kill) begin
	    esn.inst = Bundle::Bubble;
	    esn.wb_addr = 0;
	    esn.ctrl_rf_wen = 1'b0;
	    esn.ctrl_mem_val = 1'b0;
	    esn.ctrl_mem_fcn = Bundle::M_X;
	    esn.ctrl_mem_typ = Bundle::MT_X;
	    esn.ctrl_csr_cmd = ctl.csr_cmd;
	    esn.ctrl_br_type = Bundle::BR_N;
	 end else begin
	    esn.inst = ids.inst;
	    esn.wb_addr = dec_wb_addr;
	    esn.ctrl_rf_wen = ctl.rf_wen;
	    esn.ctrl_mem_val = ctl.mem_val;
	    esn.ctrl_mem_fcn = ctl.mem_fcn;
	    esn.ctrl_mem_typ = ctl.mem_typ;
	    esn.ctrl_csr_cmd = ctl.csr_cmd;
	    esn.ctrl_br_type = ctl.br_type;
	 end
      end // if (!ctl.dec_stall && !ctl.ccache_stall)
   end // always_comb
   always_ff @(posedge clk) begin
      es <= esn;
   end

   // Arithmetic Logic Unit
   Bundle::AluIn alu_in;
   Bundle::AluOut alu_out;
   // alu input
   always_comb begin
      alu_in.op1 = es.op1_data;
      alu_in.op2 = es.op2_data;
      alu_in.fun = es.ctrl_alu_fun;
   end
      
   Alu alu(/*AUTOINST*/
	   // Interfaces
	   .alu_in			(alu_in),
	   .alu_out			(alu_out));

   
   
   /// Memory Stage
   always_comb begin
      // default assignment
      msn = ms;
      // branch calculation
      if (ctl.pipeline_kill) begin
	 msn.pc = '0;
	 msn.ctrl_mem_val = 1'b0;
	 msn.ctrl_rf_wen = 1'b0;
      end else if (!ctl.cmiss_stall) begin
	 msn.pc = es.pc;
	 msn.inst = es.inst;
	 msn.alu_out = (es.ctrl_wb_sel == Bundle::WB_PC4) ? (es.pc + 4) : alu_out.data;
	 msn.wb_addr = es.wb_addr;
	 msn.rs1_addr = es.rs1_addr;
	 msn.rs2_addr = es.rs2_addr;
	 msn.op1_data = es.op1_data;
	 msn.op2_data = es.op2_data;
	 msn.rs2_data = es.rs2_data;
	 msn.ctrl_rf_wen = es.ctrl_rf_wen;
	 msn.ctrl_mem_val = es.ctrl_mem_val;
	 msn.ctrl_mem_fcn = es.ctrl_mem_fcn;
	 msn.ctrl_mem_typ = es.ctrl_mem_typ;
	 msn.ctrl_wb_sel = es.ctrl_wb_sel;
	 msn.ctrl_csr_cmd = es.ctrl_csr_cmd;
      end // if (!ctl.cmiss_stall)
   end // always_comb
   always_ff @(posedge clk) begin
      ms <= msn;
   end

   CSRFile csr_file(.csr_cmd(ms.ctrl_csr_cmd),
		    .csr(ms.inst[31:20]),
		    .csr_wdata(ms.alu_out),
		    /*AUTOINST*/
		    // Outputs
		    .csr_rdata		(csr_rdata[31:0]),
		    .csr_stall		(csr_stall),
		    .csr_read_illegal	(csr_read_illegal),
		    .csr_write_illegal	(csr_write_illegal),
		    .csr_system_illegal	(csr_system_illegal),
		    // Inputs
		    .clk		(clk));
   
   /// Write Back Stage
   /// Writeback data mux
   assign mem_wb_data = (ms.ctrl_wb_sel == Bundle::WB_ALU) ? ms.alu_out :
			(ms.ctrl_wb_sel == Bundle::WB_PC4) ? ms.alu_out :
			(ms.ctrl_wb_sel == Bundle::WB_MEM) ? dmem_out.res.data :
			(ms.ctrl_wb_sel == Bundle::WB_CSR) ? csr_rdata :
			ms.alu_out;

   always_comb begin
      // default assignment
      wbsn = wbs;
      if (!ctl.cmiss_stall) begin
	 wbsn.wb_addr = ms.wb_addr;
	 wbsn.wb_data = mem_wb_data;
	 wbsn.ctrl_rf_wen = ms.ctrl_rf_wen; // TODO(Christian) Exception handling
      end else begin
	 wbsn.ctrl_rf_wen = 1'b0;
      end
   end // always_comb
   always_ff @(posedge clk) begin
      wbs <= wbsn;
   end

   // external signals
   always_comb begin
      dat.dec_inst = ids.inst;
      dat.exe_br_eq = (es.op1_data == es.rs2_data);
      dat.exe_br_lt = ($signed(es.op1_data) < $signed(es.rs2_data));
      dat.exe_br_ltu = (es.op1_data < es.rs2_data);
      dat.exe_br_type = es.ctrl_br_type;
   end
   
   // datapath to memory signals
   always_comb begin
      dmem_in.req_valid = ms.ctrl_mem_val;
      dmem_in.req.addr = ms.alu_out;
      dmem_in.req.fcn = ms.ctrl_mem_fcn;
      dmem_in.req.typ = ms.ctrl_mem_typ;
      dmem_in.req.data = ms.rs2_data;
   end

   always_comb begin
      if (0) begin
	 $display("cyc %b: (0x%x, 0x%x, 0x%x) WB[%c%c %x: 0x%x] %c %c", reset, ifs.pc, ids.pc, es.pc, wbs.ctrl_rf_wen ? "M" : " ", ms.ctrl_rf_wen ? "Z" : " ", wbs.wb_addr, wbs.wb_data,
		  ctl.cmiss_stall ? "F" : ctl.dec_stall ? "S" : " ", ctl.exe_pc_sel == 1 ? "B" :
		  ctl.exe_pc_sel == 2 ? "J" :
		  ctl.exe_pc_sel == 3 ? "E" :
		  ctl.exe_pc_sel == 0 ? " " : "?");
      end
   end
endmodule
