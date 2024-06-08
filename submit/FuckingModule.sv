module FuckingModule (
  input clk,
  input rstn,
  input PCstall,
  input [63:0] rdata_mem,
  output reg IF_stall,
  output reg [63:0] rdata_mem_delay
);
  always @(posedge clk or negedge rstn) begin
    if (rstn == 0) begin
        rdata_mem_delay <= 0;
        IF_stall <= 0;
    end else begin
        rdata_mem_delay <= rdata_mem;
        IF_stall <= PCstall;
    end
  end
endmodule
