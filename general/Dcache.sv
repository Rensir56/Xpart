`include "MMUStruct.vh"

module Dcache #(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer BANK_NUM   = 4,
    parameter integer CAPACITY   = 1024
) (
    input                     clk,
    input                     rstn,
    input  [  ADDR_WIDTH-1:0] addr_cpu,
    input  [  DATA_WIDTH-1:0] wdata_cpu,
    input                     wen_cpu,
    input  [DATA_WIDTH/8-1:0] wmask_cpu,
    input                     ren_cpu,
    output [  DATA_WIDTH-1:0] rdata_cpu,
    output                    data_stall,
    input                     switch_mode,

    input MMUStruct::DcacheCtrl dcache_ctrl,

    Mem_ift.Master mem_ift,

    input  [  ADDR_WIDTH-1:0] dmmu_address,
    input                     dmmu_ren,
    output [  DATA_WIDTH-1:0] dmmu_rdata,
    output                    dmmu_miss_cache,

    input  [  ADDR_WIDTH-1:0] immu_address,
    input                     immu_ren,
    output [  DATA_WIDTH-1:0] immu_rdata,
    output                    immu_miss_cache
);

//set

    DCacheWrap #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (BANK_NUM),
        .CAPACITY  (CAPACITY)
    ) dcache_wrap (
        .clk         (clk),
        .rstn        (rstn),
        .addr_cpu    (addr_cpu),
        .wdata_cpu   (wdata_cpu),
        .wen_cpu     (wen_cpu),
        .wmask_cpu   (wmask_cpu),
        .ren_cpu     (ren_cpu),
        .rdata_cpu   (rdata_cpu),
        .stall_cpu   (data_stall),
        .switch_mode (switch_mode),
        .cache_enable(dcache_ctrl.dcache_enable),
        .mem_ift     (mem_ift),

        .dmmu_address (dmmu_address),
        .dmmu_ren     (dmmu_ren),
        .dmmu_rdata   (dmmu_rdata),
        .dmmu_miss_cache (dmmu_miss_cache),
        
        .immu_address (immu_address),
        .immu_ren     (immu_ren),
        .immu_rdata   (immu_rdata),
        .immu_miss_cache (immu_miss_cache)
    );


endmodule
