module InstructionDecode();
   // instruction decode stage
   // register addresses
   assign dec_rs1_addr[4:0] = ids.inst[19:15];
   assign dec_rs2_addr[4:0] = ids.inst[24:20];
   assign dec_wb_addr[4:0] = ids.inst[11:7];

   // register file i/o
   Bundle::RegisterFileOut rf_out;
   Bundle::RegisterFileIn rf_in;
   assign rf_in.rs1_addr = dec_rs1_addr;
   assign rf_in.rs2_addr = dec_rs2_addr;
   assign rf_in.waddr = wbs.wb_addr;
   assign rf_in.wdata = wbs.wb_data;
   assign rf_in.we = wbs.ctrl_rf_wen;

   RegisterFile register_file(/*AUTOINST*/
                              // Interfaces
                              .rf_in               (rf_in),
                              .rf_out              (rf_out),
                              // Inputs
                              .clk                 (clk));



   // immediate variables
   // immediates
   logic [11:0] imm_itype = ids.inst[31:20];
   logic [11:0] imm_stype = {ids.inst[31:25],ids.inst[11:7]};
   logic [11:0] imm_sbtype = {ids.inst[31],ids.inst[7],ids.inst[30:25],ids.inst[11:8]};
   logic [19:0] imm_utype = ids.inst[31:12];
   logic [19:0] imm_ujtype = {ids.inst[31], ids.inst[19:12], ids.inst[20], ids.inst[30:21]};
   logic [31:0] imm_z = {27'b0,ids.inst[19:15]};

   // sign extended immediates
   logic [31:0] imm_itype_sext  = {{20{imm_itype[11]}}, imm_itype};
   logic [31:0] imm_stype_sext  = {{20{imm_stype[11]}}, imm_stype};
   logic [31:0] imm_sbtype_sext = {{19{imm_sbtype[11]}}, imm_sbtype, 1'b0};
   logic [31:0] imm_utype_sext  = {imm_utype, 12'b0};
   logic [31:0] imm_ujtype_sext = {{11{imm_ujtype[19]}}, imm_ujtype, 1'b0};


   // operand 2 multiplexer
   assign dec_alu_op2[31:0] = (ctl.op2_sel == Bundle::OP2_RS2)    ? rf_out.rs2_data[31:0] :
                       (ctl.op2_sel == Bundle::OP2_ITYPE)  ? imm_itype_sext[31:0] :
                       (ctl.op2_sel == Bundle::OP2_STYPE)  ? imm_stype_sext[31:0] :
                       (ctl.op2_sel == Bundle::OP2_SBTYPE) ? imm_sbtype_sext[31:0] :
                       (ctl.op2_sel == Bundle::OP2_UTYPE)  ? imm_utype_sext[31:0] :
                       (ctl.op2_sel == Bundle::OP2_UJTYPE) ? imm_ujtype_sext[31:0] :
                       32'b0;
endmodule
