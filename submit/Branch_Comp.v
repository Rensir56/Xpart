module Branch_Comp(
    input [63:0] rs1,
    input [63:0] rs2,
    input [1:0] rs1_forwarding,
    input [1:0] rs2_forwarding,
    input [63:0] MEMalu_res,
    input [63:0] rd_data,
    input [2:0] bralu_op,
    output br_taken
);
    wire [63:0] rs1_data = (rs1_forwarding == 2'b01) ? MEMalu_res :
                           (rs1_forwarding == 2'b10) ? rd_data : rs1;
    wire [63:0] rs2_data = (rs2_forwarding == 2'b01) ? MEMalu_res :
                           (rs2_forwarding == 2'b10) ? rd_data : rs2;
    wire signed [63:0] signrs1 = rs1_data;
    wire signed [63:0] signrs2 = rs2_data;
    assign br_taken = (bralu_op == 3'b000) ? 0 :
                      (bralu_op == 3'b001) ? (rs1_data == rs2_data ? 1 : 0) :
                      (bralu_op == 3'b010) ? (rs1_data != rs2_data ? 1 : 0) :
                      (bralu_op == 3'b011) ? (signrs1 < signrs2 ? 1 : 0) :
                      (bralu_op == 3'b100) ? (signrs1 >= signrs2 ? 1 : 0) :
                      (bralu_op == 3'b101) ? (rs1_data < rs2_data ? 1 : 0) :
                      (rs1_data >= rs2_data ? 1 : 0);
endmodule