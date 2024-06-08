`timescale 1ns/1ps
module Data_Trunc(
    input  [63:0] alu_res,
    input  [2:0] memdata_width,
    input  [63:0] rdata,
    input [2:0] shift,
    output reg [63:0] rd_data
    );

    always@(*)begin
        case (memdata_width)
            3'b000:begin
                rd_data=alu_res;
            end
            3'b001:begin//d
                rd_data=rdata;
            end
            3'b010:begin//w
                case(shift[2])
                    1'b0:rd_data={{32{rdata[31]}},rdata[31:0]};
                    1'b1:rd_data={{32{rdata[63]}},rdata[63:32]};
                endcase
            end
            3'b011:begin//h
                case(shift[2:1])
                    2'b00:rd_data={{48{rdata[15]}},rdata[15:0]};
                    2'b01:rd_data={{48{rdata[31]}},rdata[31:16]};
                    2'b10:rd_data={{48{rdata[47]}},rdata[47:32]};
                    2'b11:rd_data={{48{rdata[63]}},rdata[63:48]};
                endcase
            end
            3'b100:begin //b
                case(shift[2:0])
                    3'b000:rd_data={{56{rdata[7]}},rdata[7:0]};
                    3'b001:rd_data={{56{rdata[15]}},rdata[15:8]};
                    3'b010:rd_data={{56{rdata[23]}},rdata[23:16]};
                    3'b011:rd_data={{56{rdata[31]}},rdata[31:24]};
                    3'b100:rd_data={{56{rdata[39]}},rdata[39:32]};
                    3'b101:rd_data={{56{rdata[47]}},rdata[47:40]};
                    3'b110:rd_data={{56{rdata[55]}},rdata[55:48]};
                    3'b111:rd_data={{56{rdata[63]}},rdata[63:56]};
                endcase
            end
            3'b101:begin//wu
                case(shift[2])
                    1'b0:rd_data={32'b0,rdata[31:0]};
                    1'b1:rd_data={32'b0,rdata[63:32]};
                endcase
            end
            3'b110:begin//hu
                case(shift[2:1])
                    2'b00:rd_data={48'b0,rdata[15:0]};
                    2'b01:rd_data={48'b0,rdata[31:16]};
                    2'b10:rd_data={48'b0,rdata[47:32]};
                    2'b11:rd_data={48'b0,rdata[63:48]};
                endcase
            end
            3'b111:begin //bu
                case(shift[2:0])
                    3'b000:rd_data={56'b0,rdata[7:0]};
                    3'b001:rd_data={56'b0,rdata[15:8]};
                    3'b010:rd_data={56'b0,rdata[23:16]};
                    3'b011:rd_data={56'b0,rdata[31:24]};
                    3'b100:rd_data={56'b0,rdata[39:32]};
                    3'b101:rd_data={56'b0,rdata[47:40]};
                    3'b110:rd_data={56'b0,rdata[55:48]};
                    3'b111:rd_data={56'b0,rdata[63:56]};
                endcase
            end
        endcase
    end
    
endmodule
