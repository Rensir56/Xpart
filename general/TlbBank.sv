module TlbBank #(
    parameter integer ADDR_WIDTH = 64,
    // parameter integer DATA_WIDTH = 64,
    parameter integer PPN_WIDTH = 44,
    parameter integer VPN_WIDTH = 27,
    parameter integer CAPACITY   = 256
) (
    input clk,
    input rstn,

    input  [  ADDR_WIDTH-1:0] addr_cpu,
    input                     ren_cpu,
    output [  ADDR_WIDTH-1:0] paddr_cpu,
    output                    hit_cpu,
    

    output [  ADDR_WIDTH-1:0] addr_tlb,
    output                    miss_tlb,
    input                     busy_rd,
    input  [  ADDR_WIDTH-1:0] addr_rd,
    input  [  ADDR_WIDTH-1:0] paddr_rd,//data_rd,
    input                     wen_rd,
    input                     finish_rd,
    input                     satp_change
);

    localparam LINE_NUM = CAPACITY;
    localparam INDEX_LEN = $clog2(LINE_NUM);
    localparam TAG_LEN = VPN_WIDTH - INDEX_LEN;

    typedef logic [TAG_LEN-1:0] tag_t;
    typedef logic [INDEX_LEN-1:0] index_t;


   typedef struct {
        logic  valid;
        tag_t  tag;
        logic [PPN_WIDTH-1:0] ppn;

   } TlbLine;

    TlbLine set        [LINE_NUM-1:0];

    tag_t     tag_cpu;
    index_t   index_cpu;

    assign tag_cpu    = addr_cpu[ADDR_WIDTH-1:ADDR_WIDTH-TAG_LEN];
    assign index_cpu  = addr_cpu[ADDR_WIDTH-TAG_LEN-1:ADDR_WIDTH-TAG_LEN-INDEX_LEN];


    tag_t    tag_rd;
    index_t  index_rd;

    assign tag_rd    = addr_rd[ADDR_WIDTH-1:ADDR_WIDTH-TAG_LEN];
    assign index_rd  = addr_rd[ADDR_WIDTH-TAG_LEN-1:ADDR_WIDTH-TAG_LEN-INDEX_LEN];

    TlbLine                  index_line;
    assign index_line = set[index_cpu];

    logic [PPN_WIDTH-1:0] ppn_cpu;

    assign hit_cpu = (index_line.tag == tag_cpu) & index_line.valid;
    assign ppn_cpu = hit_cpu ? index_line.ppn : {PPN_WIDTH{1'b0}};
    assign paddr_cpu = {8'b0 ,ppn_cpu, addr_cpu[11:0]};

    wire                miss_happen = ~hit_cpu & (ren_cpu);
    assign miss_tlb = miss_happen & ~busy_rd;
    assign addr_tlb = addr_cpu;//{addr_cpu[TAG_END:INDEX_BEGIN], pad_zero};
    integer i;
    integer j;
    always @(posedge clk) begin
        if (~rstn) begin
            for (i = 0; i < LINE_NUM; i = i + 1) begin
                set[i].valid <= 1'b0;
            end
        end else if (finish_rd) begin
            set[index_rd].valid <= 1'b1;
            set[index_rd].tag <= tag_rd;
        end else if (miss_tlb) begin
            set[index_cpu].valid <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (~rstn | satp_change) begin
            for (j = 0; j < LINE_NUM; j = j + 1) begin
                set[j].ppn <= {PPN_WIDTH {1'b0}};
            end
        end else begin
                for (j = 0; j < LINE_NUM; j = j + 1) begin
                        if (wen_rd & index_rd == j[INDEX_LEN-1:0]) begin
                            set[j].ppn <= paddr_rd[ADDR_WIDTH-1:ADDR_WIDTH-PPN_WIDTH];
                        end
                end
        end
    end
endmodule