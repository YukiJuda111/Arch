`timescale 1ps/1ps

module HazardDetectionUnit(
    input clk,
    input Branch_ID, rs1use_ID, rs2use_ID,
    input[1:0] hazard_optype_ID,
    input[4:0] rd_EXE, rd_MEM, rs1_ID, rs2_ID, rs2_EXE,
    input [6:0] op_EXE, op_MEM,
    output PC_EN_IF, reg_FD_EN, reg_FD_stall, reg_FD_flush,
        reg_DE_EN, reg_DE_flush, reg_EM_EN, reg_EM_flush, reg_MW_EN,
    output forward_ctrl_ls,
    output[1:0] forward_ctrl_A, forward_ctrl_B
);
            //according to the diagram, design the Hazard Detection Unit
    parameter LUI   = 7'b0110111;
    parameter AUIPC = 7'b0010111;
    parameter JAL   = 7'b1101111;
    parameter JALR  = 7'b1100111;
    parameter Rop   = 7'b0110011;
    parameter Iop   = 7'b0010011;
    parameter Bop   = 7'b1100011;
    parameter Lop   = 7'b0000011;
    parameter Sop   = 7'b0100011;
    wire ALUuse_EXE = (op_EXE == LUI) | (op_EXE == AUIPC) | (op_EXE == JALR) | (op_EXE == JAL) | (op_EXE == Rop) | (op_EXE == Iop);
    wire ALUuse_MEM = (op_MEM == LUI) | (op_MEM == AUIPC) | (op_MEM == JALR) | (op_MEM == JAL) | (op_MEM == Rop) | (op_MEM == Iop);
    wire rs1alu_EXE = ALUuse_EXE & ((rd_EXE == rs1_ID) & (rd_EXE != 0));
    wire rs1alu_MEM = ALUuse_MEM & ((rd_MEM == rs1_ID) & (rd_MEM != 0));
    wire rs1mem = (op_MEM == Lop) & ((rd_MEM == rs1_ID) & (rd_MEM != 0));
    wire rs2alu_EXE = ALUuse_EXE & ((rd_EXE == rs2_ID) & (rd_EXE != 0));
    wire rs2alu_MEM = ALUuse_MEM & ((rd_MEM == rs2_ID) & (rd_MEM != 0));
    wire rs2mem = (op_MEM == Lop) & ((rd_MEM == rs2_ID) & (rd_MEM != 0));
    
    assign forward_ctrl_A = {2{rs1use_ID & rs1alu_EXE}} & 2'b01 |
                            {2{rs1use_ID & ~rs1alu_EXE & rs1alu_MEM}} & 2'b10 |
                            {2{rs1use_ID & ~rs1alu_EXE & rs1mem}} & 2'b11 ;
    assign forward_ctrl_B = {2{rs2use_ID & rs2alu_EXE}}& 2'b01 |
                            {2{rs2use_ID & ~rs2alu_EXE & rs2alu_MEM}} & 2'b10 |
                            {2{rs2use_ID & ~rs2alu_EXE & rs2mem}} & 2'b11 ;
                            
    assign forward_ctrl_ls = (op_EXE == Sop) & (op_MEM == Lop) & (rd_MEM == rs2_EXE) & (rd_MEM != 0);                        
    assign PC_EN_IF = ~(hazard_optype_ID == 2'b11);  // LD - LS : PC_EN <- 0
    assign reg_FD_EN = 1;
    assign reg_DE_EN = 1;
    assign reg_EM_EN = 1;
    assign reg_MW_EN = 1;
    assign reg_FD_flush = hazard_optype_ID == 2'b10; // control hazard : IFID flush
    assign reg_DE_flush = hazard_optype_ID == 2'b11; // LD - LS : IDEX flush
    assign reg_EM_flush = 0;
    assign reg_FD_stall = hazard_optype_ID == 2'b11; // LD - LS ��IFID stall
endmodule