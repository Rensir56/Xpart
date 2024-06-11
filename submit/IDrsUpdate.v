module IDrsUpdate(    
    input clk, 
    input rstn,
    input IDEXstall,
    input IDEXflush,
    input [63:0] IDrs1,
    input [63:0] IDrs2,
    input [1:0] rs1_forwarding,
    input [1:0] rs2_forwarding,
    input we_reg,
    input [63:0] rd_data,
    output reg [63:0] EXrs1,
    output reg [63:0] EXrs2
);   

    wire flag1;
    wire flag2;

    assign flag1 = IDEXstall && rs1_forwarding == 2'b10 && we_reg;
    assign flag2 = IDEXstall && rs2_forwarding == 2'b10 && we_reg;

    always @(posedge clk or negedge rstn) begin
        if(rstn == 0 || IDEXflush == 1)begin
            EXrs1 <= 0;
        end else if(IDEXstall == 0)begin
            EXrs1 <= IDrs1;
        end else if(flag1 == 1) begin
            EXrs1 <= rd_data;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(rstn == 0 || IDEXflush == 1)begin
            EXrs2 <= 0;
        end else if(IDEXstall == 0)begin
            EXrs2 <= IDrs2;
        end else if (flag2 == 1) begin
            EXrs2 <= rd_data;
        end
    end
endmodule    