module TLB #(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer BANK_NUM   = 4,
    parameter integer CAPACITY   = 1024
) (
    input                     clk,
    input                     rstn,
    input  [  ADDR_WIDTH-1:0] addr_cpu,
    // input  [  DATA_WIDTH-1:0] wdata_cpu,
    // input                     wen_cpu,
    // input  [DATA_WIDTH/8-1:0] wmask_cpu,
    input                     ren_cpu,
    output [  DATA_WIDTH-1:0] rdata_cpu,
    output                    data_stall,
    input                     switch_mode,
    input                     satp_change,

    Mem_ift.Master mem_ift
);
    wire                      ren_mem;
    // wire                      wen_mem;
    wire [    ADDR_WIDTH-1:0] raddr_mem;
    // wire [    ADDR_WIDTH-1:0] waddr_mem;
    // wire [  DATA_WIDTH*2-1:0] wdata_mem;
    // wire [DATA_WIDTH*2/8-1:0] wmask_mem;
    wire [  DATA_WIDTH*2-1:0] rdata_mem;
    // wire                      wvalid_mem;
    wire                      rvalid_mem;

    // assign mem_ift.Mw.waddr = waddr_mem;
    assign mem_ift.Mr.raddr = raddr_mem;
    // assign mem_ift.Mw.wen   = wen_mem;
    assign mem_ift.Mr.ren   = ren_mem;
    // assign mem_ift.Mw.wdata = wdata_mem;
    // assign mem_ift.Mw.wmask = wmask_mem;
    assign rdata_mem        = mem_ift.Sr.rdata;
    assign rvalid_mem       = mem_ift.Sr.rvalid;
    // assign wvalid_mem       = mem_ift.Sw.wvalid;  

    localparam BYTE_NUM = DATA_WIDTH / 8;
    localparam LINE_NUM = CAPACITY / 2 / (BANK_NUM * BYTE_NUM);
    localparam GRANU_LEN = $clog2(BYTE_NUM);
    localparam GRANU_BEGIN = 0;
    localparam GRANU_END = GRANU_BEGIN + GRANU_LEN - 1;
    localparam OFFSET_LEN = $clog2(BANK_NUM);
    localparam OFFSET_BEGIN = GRANU_END + 1;
    localparam OFFSET_END = OFFSET_BEGIN + OFFSET_LEN - 1;
    localparam INDEX_LEN = $clog2(LINE_NUM);
    localparam INDEX_BEGIN = OFFSET_END + 1;
    localparam INDEX_END = INDEX_BEGIN + INDEX_LEN - 1;
    localparam TAG_BEGIN = INDEX_END + 1;
    localparam TAG_END = ADDR_WIDTH - 1;
    localparam TAG_LEN = ADDR_WIDTH - TAG_BEGIN;
    typedef logic [TAG_LEN-1:0] tag_t;
    typedef logic [INDEX_LEN-1:0] index_t;
    typedef logic [OFFSET_LEN-1:0] offset_t;
    typedef logic [BANK_NUM*DATA_WIDTH-1:0] data_t;

    wire [         ADDR_WIDTH-1:0] addr_wb;
    wire [BANK_NUM*DATA_WIDTH-1:0] data_wb;
    wire                           busy_wb;
    wire                           need_wb;

    wire [         ADDR_WIDTH-1:0] addr_tlb;
    wire                           miss_tlb;
    wire                           set_tlb;
    wire                           busy_rd;
    wire [         ADDR_WIDTH-1:0] addr_rd;
    wire [       DATA_WIDTH*2-1:0] data_rd;
    wire                           wen_rd;
    wire                           set_rd;
    wire                           finish_rd;  

    wire                           hit_cpu;
    
    TlbBank #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (BANK_NUM),
        .CAPACITY  (CAPACITY)
    ) tlb_bank (
        .clk      (clk),
        .rstn     (rstn),
        .addr_cpu (addr_cpu),
        // .wdata_cpu(wdata_cpu),
        // .wen_cpu  (wen_cpu),
        // .wmask_cpu(wmask_cpu),
        .ren_cpu  (ren_cpu),
        .rdata_cpu(rdata_cpu),
        .hit_cpu  (hit_cpu),

        .addr_wb(addr_wb),
        .data_wb(data_wb),
        .busy_wb(busy_wb),
        .need_wb(need_wb),

        .addr_tlb(addr_tlb),
        .miss_tlb(miss_tlb),
        .set_tlb (set_tlb),

        .busy_rd  (busy_rd),
        .addr_rd  (addr_rd),
        .data_rd  (data_rd),
        .wen_rd   (wen_rd),
        .set_rd   (set_rd),
        .finish_rd(finish_rd),
        .satp_change(satp_change)
    );  

    wire [  ADDR_WIDTH-1:0] addr_mem;
    wire [DATA_WIDTH*2-1:0] data_mem;
    wire [  OFFSET_LEN-2:0] bank_index;
    wire                    finish_wb;
    TlbWriteBuffer #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (BANK_NUM)
    ) tlb_write_buffer (
        .clk       (clk),
        .rstn      (rstn),
        .addr_wb   (addr_wb),
        .data_wb   (data_wb),
        .busy_wb   (busy_wb),
        .need_wb   (need_wb),
        .miss_tlb(miss_tlb),

        .addr_mem  (addr_mem),
        .data_mem  (data_mem),
        .bank_index(bank_index),
        .finish_wb (finish_wb)
    );


    TMU #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BANK_NUM  (BANK_NUM),
        .CAPACITY  (CAPACITY)
    )tmu(
        .clk(clk),
        .rstn(rstn),

        .addr_tlb(addr_tlb),
        .miss_tlb(miss_tlb),
        .set_tlb(set_tlb),
        .busy_rd(busy_rd),

        .rvalid_mem(rvalid_mem),
        .busy_wb(busy_wb),

        .rdata_mem(rdata_mem),
        .raddr_mem(raddr_mem),
        .ren_mem(ren_mem),

        .addr_rd(addr_rd),
        .data_rd(data_rd),
        .set_rd(set_rd),
        .wen_rd(wen_rd),

        .finish_rd(finish_rd),

        // .bank_index(bank_index),
        // .addr_mem(addr_mem),
        // .data_mem(data_mem),
        // .wvalid_mem(wvalid_mem),

        // .waddr_mem(waddr_mem),
        // .wmask_mem(wmask_mem),
        // .wen_mem(wen_mem),
        // .wdata_mem(wdata_mem),
        .finish_wb(finish_wb)
    );

    assign data_stall = ren_cpu & ~hit_cpu;

endmodule