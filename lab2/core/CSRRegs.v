`timescale 1ns / 1ps

module CSRRegs(
    input clk, rst,
    input[4:0] trap,
    input mret,
    input[11:0] rwaddr,
    input[31:0] wdata, pc, einst, eaddr,
    input csr_w,
    input[1:0] csr_wsc_mode,
    output[31:0] rdata, mtvec, mepc, mstatus
);
    // You may need to modify this module for better efficiency
    
    reg[31:0] CSR [0:15];
    // Address mapping. The address is 12 bits, but only 4 bits are used in this module.
    wire rwaddr_valid = rwaddr[11:7] == 5'h6 && rwaddr[5:3] == 3'h0;
    wire[3:0] rwaddr_map = (rwaddr[6] << 3) + rwaddr[2:0];

    assign mstatus = CSR[0];
    assign mtvec = CSR[5];
    assign mepc = CSR[9];

    assign rdata = {32{rwaddr_valid}} & CSR[rwaddr_map];

    always@(posedge clk or posedge rst) begin
        if(rst) begin
			CSR[0] <= 32'h88;   // mstatus
			CSR[1] <= 0;
			CSR[2] <= 0;
			CSR[3] <= 0;
			CSR[4] <= 0;
			CSR[5] <= 0;        // mtvec
			CSR[6] <= 0;       
			CSR[7] <= 0;
			CSR[8] <= 0;
			CSR[9] <= 0;        // mepc
			CSR[10] <= 0;       // mcause
			CSR[11] <= 0;       // mtval
			CSR[12] <= 32'habcd; 
			CSR[13] <= 0;
			CSR[14] <= 0;
			CSR[15] <= 0;
		end
		else if(mret & ~mstatus[3]) begin
		    CSR[0][7] <= CSR[0][3];   // mpie <- mie
		    CSR[0][3] <= 1'b1;   // mie <- 1
		    CSR[0][12:11] <= 2'b00;   // mpp <- 00
		end
		else if((|trap) & mstatus[3]) begin
		    CSR[0][7] <= CSR[0][3];   // mpie <- mie
		    CSR[0][3] <= 1'b0;   // mie <- 1
		    CSR[0][12:11] <= 2'b11;   // mpp <- 11
		    CSR[9] <= pc;    // mepc <- pc
		    CSR[10] <= {32{trap[0]}} & 32'h00000008 | 
		               {32{trap[1]}} & 32'h00000007 |
		               {32{trap[2]}} & 32'h00000005 |
		               {32{trap[3]}} & 32'h00000002 |
		               {32{trap[4]}} & 32'h8000000b ; // mcause
		    CSR[11] <= {32{trap[3] | trap[4]}} & einst |
		               {32{trap[1] | trap[2]}}           & eaddr ;    // mtval
		end
        else if(csr_w & rwaddr_valid) begin
            case(csr_wsc_mode)
                2'b01: CSR[rwaddr_map] = wdata;
                2'b10: CSR[rwaddr_map] = CSR[rwaddr_map] | wdata;
                2'b11: CSR[rwaddr_map] = CSR[rwaddr_map] & ~wdata;
                default: CSR[rwaddr_map] = wdata;
            endcase            
        end
    end
endmodule