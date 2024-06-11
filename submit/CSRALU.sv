module CSRALU (
  input  [63:0] csr_val_EX, 
  input  [63:0] rs1_data, 
  input  [1:0]  CSRalu_op, 
  output [63:0] CSRres

);
  parameter   RW  = 2'b01,
              RS  = 2'b10,
              RC  = 2'b11;
  reg [63:0] result;
  reg [63:0] _rs1_data = ~rs1_data;
  assign CSRres = result;
  always @(*) begin
    case (CSRalu_op)
        RW: result = rs1_data > 0 ?rs1_data:csr_val_EX;
        RS: result = csr_val_EX | rs1_data;
        RC: result = csr_val_EX & _rs1_data;
        default: result = 0;
    endcase
  end
endmodule
