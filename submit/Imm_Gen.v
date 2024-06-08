module Imm_Gen(
    input [31:0] inst,
    input [2:0] immgen_op,
    output reg [63:0] imm
);

    parameter Itype=3'b001;
    parameter Utype=3'b100;
    parameter Stype=3'b010;
    parameter Btype=3'b011;
    parameter Jtype=3'b101;


    always@(*) begin
        case (immgen_op)
            Itype:begin
                imm={{52{inst[31]}},inst[31:20]};
            end
            Utype:begin
                imm={{32{inst[31]}},inst[31:12],12'b0};
            end
            Stype:begin
                imm={{52{inst[31]}},inst[31:25],inst[11:7]};
            end
            Btype:begin
                imm={{52{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
            end
            Jtype:begin
                imm={{44{inst[31]}},inst[19:12],inst[20],inst[30:21],1'b0};
            end
            default:begin
                imm=64'b0;
            end
        endcase
    end
    

endmodule