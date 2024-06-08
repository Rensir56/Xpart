module ALU_Sel(
    input [1:0] alu_asel,
    input [1:0] alu_bsel,
    input [1:0] rs1_forwarding,
    input [1:0] rs2_forwarding,
    input [63:0] MEMalu_res,
    input [63:0] rd_data,
    input [63:0] rs1,
    input [63:0] pc,
    input [63:0] rs2,
    input [63:0] imm,
    input isBRANCH,
    input isLUI,
    output reg [63:0] A,
    output reg [63:0] B
);
    always @* begin
        if (isLUI == 1)
            A = 0;
        else if (isBRANCH == 0) begin
            if (rs1_forwarding == 1)
                A = MEMalu_res;
            else if (rs1_forwarding == 2)
                A = rd_data;
            else if (alu_asel == 2'b00)
                A = 0;
            else if (alu_asel == 2'b01)
                A = rs1;
            else
                A = pc;
        end
        else begin
            if (alu_asel == 2'b00)
                A = 0;
            else if (alu_asel == 2'b01)
                A = rs1;
            else
                A = pc;
        end
    end
    
    always @* begin
        if (isBRANCH == 0) begin
            if (rs2_forwarding == 1)
                B = MEMalu_res;
            else if (rs2_forwarding == 2)
                B = rd_data;
            else if (alu_bsel == 2'b00)
                B = 0;
            else if (alu_bsel == 2'b01)
                B = rs2;
            else
                B = imm;
        end
        else begin
            if (alu_bsel == 2'b00)
                B = 0;
            else if (alu_bsel == 2'b01)
                B = rs2;
            else
                B = imm;
        end
    end
endmodule