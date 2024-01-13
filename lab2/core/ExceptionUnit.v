`timescale 1ns / 1ps

module ExceptionUnit(
    input clk, rst,
    input csr_rw_in,
    // write/set/clear (funct bits from instruction)
    input[1:0] csr_wsc_mode_in,
    input csr_w_imm_mux,
    input[11:0] csr_rw_addr_in,
    input[31:0] csr_w_data_reg,
    input[4:0] csr_w_data_imm,
    output[31:0] csr_r_data_out,

    input interrupt,
    input illegal_inst,
    input l_access_fault,
    input s_access_fault,
    input ecall_m,

    input mret,

    input[31:0] einst,
    input[31:0] eaddr,
    input[31:0] epc_cur,
    input[31:0] epc_next,
    output[31:0] PC_redirect,
    output redirect_mux,

    output reg_FD_flush, reg_DE_flush, reg_EM_flush, reg_MW_flush, 
    output RegWrite_cancel,
    output MemWrite_cancel
);
    // According to the diagram, design the Exception Unit
    // You can modify any code in this file if needed!

    wire[31:0] mstatus, mepc, mtvec;

    wire[4:0] trap = {interrupt, illegal_inst, l_access_fault, s_access_fault, ecall_m};
    assign RegWrite_cancel = mstatus[3] & (|trap);
    assign MemWrite_cancel = mstatus[3] & (|trap);
    assign reg_FD_flush = mstatus[3] & (|trap);
    assign reg_DE_flush = mstatus[3] & (|trap);
    assign reg_EM_flush = mstatus[3] & (|trap);
    assign reg_MW_flush = mstatus[3] & (|trap);
    assign redirect_mux = (mstatus[3] & (|trap)) | mret;
    assign PC_redirect = ((|trap) & mstatus[3]) ? mtvec : mepc;

    wire [31:0] wdata = csr_w_imm_mux ? {26'b0, csr_w_data_imm} : csr_w_data_reg;
    CSRRegs csr(.clk(clk),.rst(rst),.csr_w(csr_rw_in),.trap(trap),.mret(mret),
        .pc(epc_cur),.einst(einst),.eaddr(eaddr),.rwaddr(csr_rw_addr_in),.rdata(csr_r_data_out),
        .wdata(wdata),.csr_wsc_mode(csr_wsc_mode_in),.mtvec(mtvec),.mepc(mepc),.mstatus(mstatus));

endmodule
