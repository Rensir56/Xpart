module TMU#(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer BANK_NUM   = 4,
    parameter integer CAPACITY   = 1024
)(
    input clk,
    input rstn,

    // IDLE
    input [ADDR_WIDTH - 1: 0]addr_tlb,
    input miss_tlb,
    input set_tlb,

    output reg busy_rd,
    // read
    input rvalid_mem,
    input busy_wb,  

    input [DATA_WIDTH * 2 - 1: 0]rdata_mem,
    output reg [ADDR_WIDTH - 1 : 0]raddr_mem,
    output reg ren_mem,

    output reg [ADDR_WIDTH - 1 : 0]addr_rd,
    output reg [DATA_WIDTH * 2 - 1 : 0]data_rd,
    output reg set_rd,
    output reg wen_rd,

    output reg finish_rd,
    // write
    // output reg [$clog2(BANK_NUM) - 2 : 0]bank_index,
    // input [ADDR_WIDTH - 1 : 0]addr_mem,
    // input [DATA_WIDTH * 2 - 1 : 0]data_mem,
    // input wvalid_mem,
    

    // output reg [ADDR_WIDTH - 1 : 0]waddr_mem,
    // output reg wen_mem,
    // output reg [DATA_WIDTH * 2 - 1 : 0]wdata_mem,
    // output reg [DATA_WIDTH * 2 / 8 - 1 : 0]wmask_mem,
    output reg finish_wb
);


reg [31:0]count;
reg [1:0]state;

reg [ADDR_WIDTH - 1 : 0]addr_tlb_temp;
reg set_rd_temp;

// reg [ADDR_WIDTH - 1 : 0]addr_mem_temp;
// reg [DATA_WIDTH * 2 - 1 : 0]data_mem_temp;


localparam IDLE = 2'b00;
localparam READ = 2'b01;
// localparam WRITE = 2'b10;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        count <= 0 ;
        state <= IDLE;
    end
    else begin
        case(state)
            IDLE: begin
                if(miss_tlb) begin
                    addr_tlb_temp <= addr_tlb;
                    set_rd_temp <= set_tlb;
                    
                    addr_rd <= addr_tlb;
                    set_rd <= set_tlb;
                    busy_rd <= 1;

                    raddr_mem <= addr_tlb;
                    ren_mem <= 1;

                    state <= READ;

                end
                else begin
                    finish_rd <= 0;
                    busy_rd <= 0;
                    finish_wb <= 0;
                end
            end
            READ: begin
                if(count != 2 && rvalid_mem == 1) begin 
                    wen_rd <= 1;
                    raddr_mem <= addr_tlb_temp + 16;
                    addr_rd <= addr_tlb_temp;
                    addr_tlb_temp <= addr_tlb_temp + 16;
                    data_rd <= rdata_mem;
                    set_rd <= set_tlb;
                    count <= count + 1;
                end
                else if(count == 2 && rvalid_mem == 1)begin
                    finish_rd <= 1;
                    count <= 0;

                    wen_rd <= 0;
                    data_rd <= 0;
                    raddr_mem <= 0;
                    ren_mem <= 0;
                    state <= IDLE;

                    // if(busy_wb) begin
                    //     // state <= WRITE;
                    //     // // waddr_mem <= addr_mem;
                    //     // addr_mem_temp <= addr_mem;
                    //     // bank_index <= 0;
                    // end else begin
                    //     state <= IDLE;
                    // end
                end
                    
            end
            // WRITE: begin
            //     if(count != 2) begin
            //         wdata_mem <= data_mem;
            //         wmask_mem <= 16'hFFFF;
            //         finish_wb <= 0;
            //         wen_mem <= 1;
            //         if(wvalid_mem) begin
            //             waddr_mem <= addr_mem + 16;
            //             count <= count + 1;
            //             bank_index <= bank_index + 1;
            //         end
            //     end
            //     else if(count == 2 && wvalid_mem)begin
            //         count <= 0;
            //         wen_mem <= 0;
            //         finish_wb <= 1;
            //         state <= IDLE;
            //     end
            // end
            default: begin
                
            end
        endcase
    end
end
endmodule