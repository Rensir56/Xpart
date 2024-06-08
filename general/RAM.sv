`timescale 1ns / 1ps

// Copyright 2023 Sycuricon Group
// Author: Jinyan Xu (phantom@zju.edu.cn)
module RAM #(
    parameter longint MEM_DEPTH = 4096,
    parameter FILE_PATH         = "testcase.hex"
) (
    input  clk,
    input  rstn,
    Mem_ift.Slave mem_ift
);

    wire ren;
    wire wen;
    wire [$clog2(MEM_DEPTH)-4:0] r_addr;
    wire [$clog2(MEM_DEPTH)-4:0] w_addr;
    wire [63:0] rw_wdata;
    wire [7:0] rw_wmask;
    reg [63:0] rw_rdata;
    wire wvalid;
    wire rvalid;

    assign ren=mem_ift.Mr.ren;
    assign wen=mem_ift.Mw.wen;
    assign r_addr=mem_ift.Mr.raddr[$clog2(MEM_DEPTH)-1:3];
    assign w_addr=mem_ift.Mw.waddr[$clog2(MEM_DEPTH)-1:3];
    assign rw_wdata=mem_ift.Mw.wdata;
    assign rw_wmask=mem_ift.Mw.wmask;
    assign mem_ift.Sr.rdata=rw_rdata;
    assign mem_ift.Sr.rvalid=rvalid;
    assign mem_ift.Sw.wvalid=wvalid;

    integer i;
    (* ram_style = "block" *) reg [63:0] mem [0:(MEM_DEPTH/8-1)];
    
    initial begin
        $display("%s:%d",FILE_PATH,MEM_DEPTH);
        $readmemh(FILE_PATH, mem);
    end

    always @(posedge clk) begin
        if(rstn)begin
            if (wen) begin
                for(i = 0; i < 8; i = i+1) begin
                    if(rw_wmask[i]) begin
                        mem[w_addr][i*8 +: 8] <= rw_wdata[i*8 +: 8];
                    end
                end
            end
            rw_rdata <= mem[r_addr];
        end
    end

    reg wstate;
    always@(posedge clk)begin
        if(!rstn)wstate<=1'b0;
        else if(~wen)wstate<=1'b0;
        else if(wstate==1'b0)wstate<=1'b1;
        else wstate<=wstate>>1;
    end

    assign wvalid=wstate==1'b1;

    reg rstate;
    always@(posedge clk)begin
        if(!rstn)rstate<=1'b0;
        else if(~ren)rstate<=1'b0;
        else if(rstate==1'b0)rstate<=1'b1;
        else rstate<=rstate>>1;
    end

    assign rvalid=rstate==1'b1;
    
endmodule
