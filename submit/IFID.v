module IFID(    
    input clk, 
    input rstn,
    input IFIDstall,
    input IFIDflush,
    input [63:0] IFpc,
    input [63:0] IFnpc,
    input [31:0] IFinst,
    input IFvalid,
    input IF_stall_if,
    output reg IF_stall_id,
    output reg [63:0] IDpc,
    output reg [63:0] IDnpc,
    output reg [31:0] IDinst,
    output reg IDvalid
);   
    always @(posedge clk) begin
        if(rstn == 0 || IFIDflush == 1)begin
            IDvalid <= 0;
            IDpc <= 0;
            IDnpc <= 0;
            IDinst <= 0;
            IF_stall_id <= 0;
        end else if(IFIDstall==0)begin
            IDpc <= IFpc;
            IDinst <= IFinst;
            IDvalid <= IFvalid;
            IDnpc <= IFnpc;
            IF_stall_id <= IF_stall_if;
        end
    end
endmodule    