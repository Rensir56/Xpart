`define MATHr 7'b0110011
`define MATHWr 7'b0111011
`define JAL 7'b1101111
`define BRANCH 7'b1100011
`define LUI 7'b0110111
`define AUIPC 7'b0010111

module Forwarding(
    input MEMwe_reg,
    input WBwe_reg,
    input [31:0] EXinst,
    input [4:0] MEMrd,
    input [4:0] WBrd,
    output reg [1:0] rs1_forwarding,
    output reg [1:0] rs2_forwarding
);
    wire [4:0] EXrs1 = EXinst[19:15];
    wire [4:0] EXrs2 = EXinst[24:20];
    wire [4:0] EXrd = EXinst[11:7];
    wire [6:0] opcode = EXinst[6:0];
    
    reg isR;
    reg isWR;
    reg isBRANCH;
    reg isJAL;
    reg isAUIPC;
    reg isLUI;

    always @*begin
        isR = (opcode == `MATHr);
        isWR = (opcode == `MATHWr);
        isBRANCH = (opcode == `BRANCH);
        isJAL = (opcode == `JAL);
        isLUI = (opcode == `LUI);
        isAUIPC = (opcode == `AUIPC);
    end


    always @(*) begin
        if (isJAL || isLUI)
            rs1_forwarding = 0;
        else if(EXrs1 == MEMrd && MEMrd != 0 && MEMwe_reg) begin
            rs1_forwarding = 2'b01;
        end else if(EXrs1 == WBrd && WBrd != 0 && WBwe_reg) begin
            rs1_forwarding = 2'b10;
        end else begin
            rs1_forwarding = 2'b00;
        end
    end
    
    always @(*) begin
        if (!(isR || isWR)) begin
            rs2_forwarding = 2'b00;
        end else if(EXrs2 == MEMrd && MEMrd != 0 && MEMwe_reg) begin
            rs2_forwarding = 2'b01;
        end else if(EXrs2 == WBrd && WBrd != 0 && WBwe_reg) begin
            rs2_forwarding = 2'b10;
        end else begin
            rs2_forwarding = 2'b00;
        end
    end
endmodule
