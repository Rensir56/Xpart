`include "RegStruct.vh"
module Regs (
  input         clk,
  input         rst,
  input         we,
  input         isi,
  input  [4:0]  read_addr_1,
  input  [4:0]  read_addr_2,
  input  [4:0]  write_addr,
  input  [63:0] write_data,
  output [63:0] read_data_1,
  output [63:0] read_data_2,
  output RegStruct::RegPack cosim_regs
);

  integer i;
  reg [63:0] register [1:31]; // x1 - x31, x0 keeps zero

  wire rd;
  wire rs1;

  assign read_data_1 = (read_addr_1==5'b0)?64'b0:
                       (read_addr_1 == write_addr && we)? write_data:
                       (isi==0)? register[read_addr_1]:{59'b0, read_addr_1}; // read
  assign read_data_2 = (read_addr_2==5'b0)?64'b0:
                       (read_addr_2 == write_addr && we)? write_data: register[read_addr_2]; // read

  always @(posedge clk or posedge rst) begin
      if (rst == 1) begin
        for(i=1;i<=31;i=i+1)begin
            register[i]<=64'b0;
        end
      end else if (we) 
        register[write_addr]<=write_data; // write register
  end

  genvar j;
  generate
    for(j=1;j<=31;j=j+1)begin:cosim_reg_assign
      assign cosim_regs.regs[j]=register[j];
    end
  endgenerate
  assign cosim_regs.regs[0]=64'b0;

endmodule
