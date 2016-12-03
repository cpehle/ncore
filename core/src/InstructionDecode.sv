`include "Bundle.sv"
`include "Instructions.sv"

module InstructionDecode(
                         input logic [31:0] if_instruction,
                         output Bundle::ControlSignals cs
);

   Bundle::ControlSignals cs_default;

   import Bundle::*;
   always_comb begin
      cs = cs_default;
      case (if_instruction) inside
        `BNE:     cs = '{Y,Y,N,N,Y,Y,A2_RS2, A1_RS1, IMM_SB,DW_X,  FN_SNE,   N,M_X,        MT_X, N,N,N,N,N,N,CSR_N,N,N,N};
        `BEQ:     cs = '{Y,Y,N,N,Y,Y,A2_RS2, A1_RS1, IMM_SB,DW_X,  FN_SEQ,   N,M_X,        MT_X, N,N,N,N,N,N,CSR_N,N,N,N};
        `BLT:     cs = '{Y,Y,N,N,Y,Y,A2_RS2, A1_RS1, IMM_SB,DW_X,  FN_SLT,   N,M_X,        MT_X, N,N,N,N,N,N,CSR_N,N,N,N};
        `BLTU:    cs = '{Y,Y,N,N,Y,Y,A2_RS2, A1_RS1, IMM_SB,DW_X,  FN_SLTU,  N,M_X,        MT_X, N,N,N,N,N,N,CSR_N,N,N,N};
        `BGE:     cs = '{Y,Y,N,N,Y,Y,A2_RS2, A1_RS1, IMM_SB,DW_X,  FN_SGE,   N,M_X,        MT_X, N,N,N,N,N,N,CSR_N,N,N,N};
        `BGEU:    cs = '{Y,Y,N,N,Y,Y,A2_RS2, A1_RS1, IMM_SB,DW_X,  FN_SGEU,  N,M_X,        MT_X, N,N,N,N,N,N,CSR_N,N,N,N};
        //
        `JAL:     cs = '{Y,N,Y,N,N,N,A2_FOUR,A1_PC,  IMM_UJ,DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `JALR:    cs = '{Y,N,N,Y,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `AUIPC:   cs = '{Y,N,N,N,N,N,A2_IMM, A1_PC,  IMM_U, DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        //
        `LB:      cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_ADD,   Y,M_XRD,      MT_B, N,N,N,N,N,Y,CSR_N,N,N,N};
        `LH:      cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_ADD,   Y,M_XRD,      MT_H, N,N,N,N,N,Y,CSR_N,N,N,N};
        `LW:      cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_ADD,   Y,M_XRD,      MT_W, N,N,N,N,N,Y,CSR_N,N,N,N};
        `LBU:     cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_ADD,   Y,M_XRD,      MT_BU,N,N,N,N,N,Y,CSR_N,N,N,N};
        `LHU:     cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_ADD,   Y,M_XRD,      MT_HU,N,N,N,N,N,Y,CSR_N,N,N,N};
        `SB:      cs = '{Y,N,N,N,Y,Y,A2_IMM, A1_RS1, IMM_S, DW_XPR,FN_ADD,   Y,M_XWR,      MT_B, N,N,N,N,N,N,CSR_N,N,N,N};
        `SH:      cs = '{Y,N,N,N,Y,Y,A2_IMM, A1_RS1, IMM_S, DW_XPR,FN_ADD,   Y,M_XWR,      MT_H, N,N,N,N,N,N,CSR_N,N,N,N};
        `SW:      cs = '{Y,N,N,N,Y,Y,A2_IMM, A1_RS1, IMM_S, DW_XPR,FN_ADD,   Y,M_XWR,      MT_W, N,N,N,N,N,N,CSR_N,N,N,N};
        //
        `LUI:     cs = '{Y,N,N,N,N,N,A2_IMM, A1_ZERO,IMM_U, DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `ADDI:    cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `SLTI:    cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_SLT,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `SLTIU:   cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_SLTU,  N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `ANDI:    cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_AND,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `ORI:     cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_OR,    N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `XORI:    cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_XOR,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `SLLI:    cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_SL,    N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `SRLI:    cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_SR,    N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `SRAI:    cs = '{Y,N,N,N,N,Y,A2_IMM, A1_RS1, IMM_I, DW_XPR,FN_SRA,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `ADD:     cs = '{Y,N,N,N,Y,Y,A2_RS2, A1_RS1, IMM_X, DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `SUB:     cs = '{Y,N,N,N,Y,Y,A2_RS2, A1_RS1, IMM_X, DW_XPR,FN_SUB,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `SLT:     cs = '{Y,N,N,N,Y,Y,A2_RS2, A1_RS1, IMM_X, DW_XPR,FN_SLT,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `SLTU:    cs = '{Y,N,N,N,Y,Y,A2_RS2, A1_RS1, IMM_X, DW_XPR,FN_SLTU,  N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `AND:     cs = '{Y,N,N,N,Y,Y,A2_RS2, A1_RS1, IMM_X, DW_XPR,FN_AND,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `OR:      cs = '{Y,N,N,N,Y,Y,A2_RS2, A1_RS1, IMM_X, DW_XPR,FN_OR,    N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `XOR:     cs = '{Y,N,N,N,Y,Y,A2_RS2, A1_RS1, IMM_X, DW_XPR,FN_XOR,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `SLL:     cs = '{Y,N,N,N,Y,Y,A2_RS2, A1_RS1, IMM_X, DW_XPR,FN_SL,    N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `SRL:     cs = '{Y,N,N,N,Y,Y,A2_RS2, A1_RS1, IMM_X, DW_XPR,FN_SR,    N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        `SRA:     cs = '{Y,N,N,N,Y,Y,A2_RS2, A1_RS1, IMM_X, DW_XPR,FN_SRA,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_N,N,N,N};
        //
        `FENCE:   cs = '{Y,N,N,N,N,N,A2_X,   A1_X,   IMM_X, DW_X,  FN_X,     N,M_X,        MT_X, N,N,N,N,N,N,CSR_N,N,Y,N};
        `FENCE_I: cs = '{Y,N,N,N,N,N,A2_X,   A1_X,   IMM_X, DW_X,  FN_X,     Y,M_FLUSH_ALL,MT_X, N,N,N,N,N,N,CSR_N,Y,N,N};
        // `SCALL:   cs = '{Y,N,N,N,N,X,A2_X,   A1_X,   IMM_X, DW_X,  FN_X,     N,M_X,        MT_X, N,N,N,N,N,N,CSR.I,N,N,N};
        // `SBREAK:  cs = '{Y,N,N,N,N,X,A2_X,   A1_X,   IMM_X, DW_X,  FN_X,     N,M_X,        MT_X, N,N,N,N,N,N,CSR.I,N,N,N};
        // `MRET: cs = '{Y,N,N,N,N,X,A2_X,   A1_X,   IMM_X, DW_X,  FN_X,     N,M_X,        MT_X, N,N,N,N,N,N,CSR.I,N,N,N};
        // `WFI:     cs = '{Y,N,N,N,N,X,A2_X,   A1_X,   IMM_X, DW_X,  FN_X,     N,M_X,        MT_X, N,N,N,N,N,N,CSR.I,N,N,N};
        `CSRRW:   cs = '{Y,N,N,N,N,Y,A2_ZERO,A1_RS1, IMM_X, DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_W,N,N,N};
        `CSRRS:   cs = '{Y,N,N,N,N,Y,A2_ZERO,A1_RS1, IMM_X, DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_S,N,N,N};
        `CSRRC:   cs = '{Y,N,N,N,N,Y,A2_ZERO,A1_RS1, IMM_X, DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_C,N,N,N};
        `CSRRWI:  cs = '{Y,N,N,N,N,N,A2_IMM, A1_ZERO,IMM_Z, DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_W,N,N,N};
        `CSRRSI:  cs = '{Y,N,N,N,N,N,A2_IMM, A1_ZERO,IMM_Z, DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_S,N,N,N};
        `CSRRCI:  cs = '{Y,N,N,N,N,N,A2_IMM, A1_ZERO,IMM_Z, DW_XPR,FN_ADD,   N,M_X,        MT_X, N,N,N,N,N,Y,CSR_C,N,N,N};
        default: cs = cs_default;
      endcase // case (dat.dec_inst)
   end // always_comb
endmodule
