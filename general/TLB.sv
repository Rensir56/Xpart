module TLB #(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer BANK_NUM   = 4,
    parameter integer CAPACITY   = 1024
) (
    input                     clk,
    input                     rstn,
    input  [  ADDR_WIDTH-1:0] addr_cpu,
    input  [  ADDR_WIDTH-1:0] vaddr,
    input                     ren_cpu,
    output [  DATA_WIDTH-1:0] rdata_cpu,
    output                    data_stall,
    input                     switch_mode,
    input                     satp_change,

    Mem_ift.Master mem_ift
);
    wire                      ren_mem;
    wire [    ADDR_WIDTH-1:0] raddr_mem;
    wire [    DATA_WIDTH-1:0] rdata_mem;
    wire                      rvalid_mem;

    assign rdata_mem        = mem_ift.Sr.rdata;
    assign rvalid_mem       = mem_ift.Sr.rvalid;

    // localparam BYTE_NUM = DATA_WIDTH / 8;
    // localparam LINE_NUM = CAPACITY / 2 / (BANK_NUM * BYTE_NUM);
    // localparam GRANU_LEN = $clog2(BYTE_NUM);
    // localparam GRANU_BEGIN = 0;
    // localparam GRANU_END = GRANU_BEGIN + GRANU_LEN - 1;
    // localparam OFFSET_LEN = $clog2(BANK_NUM);
    // localparam OFFSET_BEGIN = GRANU_END + 1;
    // localparam OFFSET_END = OFFSET_BEGIN + OFFSET_LEN - 1;
    // localparam INDEX_LEN = $clog2(LINE_NUM);
    // localparam INDEX_BEGIN = OFFSET_END + 1;
    // localparam INDEX_END = INDEX_BEGIN + INDEX_LEN - 1;
    // localparam TAG_BEGIN = INDEX_END + 1;
    // localparam TAG_END = ADDR_WIDTH - 1;
    // localparam TAG_LEN = ADDR_WIDTH - TAG_BEGIN;
    // typedef logic [TAG_LEN-1:0] tag_t;
    // typedef logic [INDEX_LEN-1:0] index_t;
    // typedef logic [OFFSET_LEN-1:0] offset_t;
    // typedef logic [BANK_NUM*DATA_WIDTH-1:0] data_t;
    localparam PPN_WIDTH = 44;
    localparam VPN_WIDTH = 27;

    wire [         ADDR_WIDTH-1:0] paddr_cpu;
    wire [         ADDR_WIDTH-1:0] addr_tlb;
    wire                           miss_tlb;

    wire                           busy_rd;
    wire [         ADDR_WIDTH-1:0] addr_rd;
    wire [         DATA_WIDTH-1:0] data_rd;
    wire                           wen_rd;

    wire                           finish_rd;  

    wire                           hit_cpu;
    wire [         ADDR_WIDTH-1:0] paddr_rd;

    function check_page;
        input [9:0] flags;
        begin
            check_page = !(flags[3] | flags[2] | flags[1]);
        end
    endfunction
    
    TlbBank #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .PPN_WIDTH (PPN_WIDTH),
        .VPN_WIDTH (VPN_WIDTH),
        .CAPACITY  (CAPACITY)
    ) tlb_bank (
        .clk      (clk),
        .rstn     (rstn),
        .addr_cpu (vaddr),
        .ren_cpu  (ren_cpu),
        .paddr_cpu(paddr_cpu),
        .hit_cpu  (hit_cpu),

        .addr_tlb(addr_tlb),
        .miss_tlb(miss_tlb),

        .busy_rd  (busy_rd),
        .addr_rd  (addr_rd),
        .paddr_rd  (data_rd),
        .wen_rd   (wen_rd & check_page(data_rd[ADDR_WIDTH-PPN_WIDTH-1:0])),
        .finish_rd(finish_rd),
        .satp_change(satp_change)
    );  


    TMU #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .CAPACITY  (CAPACITY)
    )tmu(
        .clk(clk),
        .rstn(rstn),

        .addr_tlb(addr_tlb),
        .miss_tlb(miss_tlb),
        .busy_rd(busy_rd),

        .rvalid_mem(rvalid_mem),

        .rdata_mem(rdata_mem),
        .raddr_mem(raddr_mem),
        .ren_mem(ren_mem),

        .addr_rd(addr_rd),
        .data_rd(data_rd),
        .wen_rd(wen_rd),

        .finish_rd(finish_rd)
    );

    assign data_stall = ren_cpu & ~hit_cpu;
    assign rdata_cpu = hit_cpu ? paddr_cpu : data_rd;
    assign paddr_rd = (data_rd >> 10) << 12;

endmodule