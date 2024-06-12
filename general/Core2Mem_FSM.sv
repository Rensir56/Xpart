module Core2Mem_FSM (
    input clk,
    input rstn,
    input wire [63:0] address_cpu,
    input wire wen_cpu,
    input wire ren_cpu,
    input wire [63:0] wdata_cpu,
    input wire [7:0] wmask_cpu,
    output [63:0] rdata_cpu,
    output mem_stall,
    Mem_ift.Master mem_ift
);

    localparam DATA_WIDTH = 64;
    localparam BYTE_NUM = DATA_WIDTH / 8;
    reg do_task;
    always@(posedge clk)begin
        if(~rstn)do_task<=1'b0;
        else if(mem_ift.Sr.rvalid|mem_ift.Sw.wvalid)do_task<=1'b0;
        else if(wen_cpu|ren_cpu)do_task<=1'b1;
    end

    assign mem_ift.Mw.waddr=address_cpu;
    assign mem_ift.Mr.raddr=address_cpu;
    assign mem_ift.Mw.wen=wen_cpu;
    assign mem_ift.Mr.ren=ren_cpu;
    assign mem_ift.Mw.wdata={wdata_cpu,wdata_cpu};
    assign mem_ift.Mw.wmask= address_cpu[$clog2(BYTE_NUM)] ? {wmask_cpu, {(BYTE_NUM) {1'b0}}} : {{(BYTE_NUM) {1'b0}}, wmask_cpu};
    //     assign direct_ift.Mw.wmask = addr_cpu[$clog2(
        // BYTE_NUM
    // )] ? {wmask_cpu, {(BYTE_NUM) {1'b0}}} : {{(BYTE_NUM) {1'b0}}, wmask_cpu};
    assign rdata_cpu = address_cpu[$clog2(BYTE_NUM)] ? mem_ift.Sr.rdata[2*DATA_WIDTH-1:DATA_WIDTH] : mem_ift.Sr.rdata[DATA_WIDTH-1:0];// mem_ift.Sr.rdata;
    // addr_cpu[$clog2(
        // BYTE_NUM
    // )] ? direct_ift.Sr.rdata[2*DATA_WIDTH-1:DATA_WIDTH] : direct_ift.Sr.rdata[DATA_WIDTH-1:0];
    assign mem_stall=(~do_task&(wen_cpu|ren_cpu))|(do_task&~mem_ift.Sr.rvalid&~mem_ift.Sw.wvalid);
    
endmodule