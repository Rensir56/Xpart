module WbtoRegs(
    input [1:0] wb_sel,
    input [63:0] alu_res,
    input [63:0] mem_data,
    input [63:0] npc,
    output reg [63:0] rd_data
    );

    always @(*) begin
        case (wb_sel)
            2'b00:begin
                rd_data=64'b0;
            end
            2'b01:begin
                rd_data=alu_res;
            end
            2'b10:begin
                rd_data=mem_data;
            end
            2'b11:begin
                rd_data=npc;
            end
        endcase
    end
endmodule