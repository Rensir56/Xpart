`define MATHr 7'b0110011
`define MATHWr 7'b0111011
`define JAL 7'b1101111
`define BRANCH 7'b1100011
`define LUI 7'b0110111
`define AUIPC 7'b0010111
`define SW 7'b0100011
`define LW 7'b0000011

module ALU_Sel(
    input [1:0] alu_asel,
    input [1:0] alu_bsel,
    input [1:0] rs1_forwarding,
    input [1:0] rs2_forwarding,
    input [63:0] MEMalu_res,
    input [63:0] rdata_mem,
    input [63:0] rd_data,
    input [63:0] rs1,
    input [63:0] pc,
    input [63:0] rs2,
    input [63:0] imm,
    input [31:0] EXinst,
    output reg [63:0] A,
    output reg [63:0] B,
    output reg [63:0] EXrs2_final
);

    reg isR;
    reg isWR;
    reg isBRANCH;
    reg isJAL;
    reg isAUIPC;
    reg isLUI;
    reg isSW;

    wire [6:0] opcode = EXinst[6:0];

    always @*begin
        isR = (opcode == `MATHr);
        isWR = (opcode == `MATHWr);
        isBRANCH = (opcode == `BRANCH);
        isJAL = (opcode == `JAL);
        isLUI = (opcode == `LUI);
        isAUIPC = (opcode == `AUIPC);
        isSW = (opcode == `SW);
    end

    always @* begin
        // if (isLUI == 1) begin
        //     A = 0;
        // end
        if (isBRANCH == 0) begin
            if (rs1_forwarding == 1) begin
                A = MEMalu_res;
            end else if (rs1_forwarding == 2) begin
                A = rd_data;
            end else if (rs1_forwarding == 3) begin
                A = rdata_mem;
            end else if (alu_asel == 2'b00) begin
                A = 0;
            end else if (alu_asel == 2'b01) begin
                A = rs1;
            end else begin
                A = pc;
            end  
        end
        else begin
            if (alu_asel == 2'b00) begin
                A = 0;
            end else if (alu_asel == 2'b01) begin
                A = rs1;
            end
            else begin
                A = pc;
            end
        end
    end
    
    always @* begin
        if (isBRANCH == 0 && isSW == 0) begin
            if (rs2_forwarding == 1) begin
                B = MEMalu_res;
            end
            else if (rs2_forwarding == 2) begin
                B = rd_data;
            end
            else if (rs2_forwarding == 3) begin
                B= rdata_mem;
            end else if (alu_bsel == 2'b00) begin
                B = 0;
            end else if (alu_bsel == 2'b01) begin
                B = rs2;
            end
            else begin
                B = imm;
            end
        end
        else begin
            if (alu_bsel == 2'b00) begin
                B = 0;
            end else if (alu_bsel == 2'b01) begin
                B = rs2;
            end else  begin
                B = imm;
            end
        end
    end

    always @(*) begin
        if (rs2_forwarding == 1) begin
            EXrs2_final = MEMalu_res;
        end
        else if (rs2_forwarding == 2) begin
            EXrs2_final = rd_data;
        end
        else if (rs2_forwarding == 3) begin
            EXrs2_final = rdata_mem;
        end else begin
            EXrs2_final = rs2;
        end
    end
endmodule