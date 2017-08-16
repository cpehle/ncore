module ImmGen(input logic [3:0] select,
              input logic [31:0]  inst,
              output logic [31:0] imm
);
   /// Immediate Variables
   /// See section 2.2 of the riscv instruction manual
   logic [11:0]                   imm_itype = inst[31:20];
   logic [11:0]                   imm_stype = {inst[31:25],inst[11:7]};
   logic [11:0]                   imm_sbtype = {inst[31],inst[7],inst[30:25],inst[11:8]};
   logic [19:0]                   imm_utype = inst[31:12];
   logic [19:0]                   imm_ujtype = {inst[31], inst[19:12], inst[20], inst[30:21]};
   logic [31:0]                   imm_z = {27'b0,inst[19:15]};

   // compute sign extended immediates
   logic [31:0]                   imm_itype_sext  = {{20{imm_itype[11]}}, imm_itype};
   logic [31:0]                   imm_stype_sext  = {{20{imm_stype[11]}}, imm_stype};
   logic [31:0]                   imm_sbtype_sext = {{19{imm_sbtype[11]}}, imm_sbtype, 1'b0};
   logic [31:0]                   imm_utype_sext  = {imm_utype, 12'b0};
   logic [31:0]                   imm_ujtype_sext = {{11{imm_ujtype[19]}}, imm_ujtype, 1'b0};

endmodule
