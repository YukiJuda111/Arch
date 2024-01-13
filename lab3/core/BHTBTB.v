`timescale 1ns / 1ps
module BHTBTB(
    input clk, rst,
    input [1:0] predict_state,
    input [31:0] PC_if, PC_id, PC_change,
    output[31:0] PC_next,
    output taken
    );
    
    reg valid [0:127];
    reg[31:0] BTB [0:127];
    reg[1:0] BHT [0:127];
    wire[6:0] if_index = PC_if[8:2];
    wire[6:0] id_index = PC_id[8:2];
    integer i;
    
    assign PC_next = BTB[if_index];
    assign taken = valid[if_index] & BHT[if_index][1];
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            for(i = 0; i < 128; i = i + 1) begin
                valid[i] <= 1'b0;
                BTB[i] <= 32'b0;
                BHT[i] <= 2'b01;
            end
        end else if(predict_state) begin
            valid[id_index] <= 1'b1;
            BTB[id_index] <= PC_change;
            case(predict_state)
                2'b11: BHT[id_index] <= {BHT[id_index][0], 1'b1};
                2'b10: BHT[id_index] <= {BHT[id_index][0], 1'b0};
                2'b01: BHT[id_index] <= {2{BHT[id_index][1]}};
                default: BHT[id_index] <= BHT[id_index];  
            endcase
        end
    end
    
endmodule
