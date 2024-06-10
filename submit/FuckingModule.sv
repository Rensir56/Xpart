module FuckingModule (
  input clk,
  input rstn,
  input PCstall,
  input [63:0] rdata_mem,
  input to_delay_request,
  output reg IF_stall,
  output reg [63:0] rdata_mem_delay,
  output reg delay_request
);
  always @(posedge clk or negedge rstn) begin
    if (rstn == 0) begin
        rdata_mem_delay <= 0;
        IF_stall <= 0;
        delay_request <= 0;
    end else begin
        rdata_mem_delay <= rdata_mem;
        IF_stall <= PCstall;
        delay_request <= to_delay_request;
    end
  end
endmodule
