module TMU#(
    parameter integer ADDR_WIDTH = 64,
    parameter integer DATA_WIDTH = 64,
    parameter integer CAPACITY   = 1024
)(
    input clk,
    input rstn,

    // IDLE
    input [ADDR_WIDTH - 1: 0]addr_tlb,
    input miss_tlb,

    output reg busy_rd,
    // read
    input rvalid_mem, 

    input [DATA_WIDTH * 2 - 1: 0]rdata_mem,
    output reg [ADDR_WIDTH - 1 : 0]raddr_mem,
    output reg ren_mem,

    output reg [ADDR_WIDTH - 1 : 0]addr_rd,
    output reg [DATA_WIDTH * 2 - 1 : 0]data_rd,
    output reg wen_rd,

    output reg finish_rd
);


reg [1:0]state;

reg [ADDR_WIDTH - 1 : 0]addr_tlb_temp;
reg set_rd_temp;


localparam IDLE = 2'b00;
localparam READ = 2'b01;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        state <= IDLE;
    end
    else begin
        case(state)
            IDLE: begin
                if (wen_rd) begin
                    finish_rd <= 1;
                    wen_rd <= 0;
                end
                if(miss_tlb) begin
                    addr_tlb_temp <= addr_tlb;
                    
                    addr_rd <= addr_tlb;
                    busy_rd <= 1;

                    raddr_mem <= addr_tlb;
                    ren_mem <= 1;

                    state <= READ;

                end
                else begin
                    finish_rd <= 0;
                    busy_rd <= 0;
                end
            end
            READ: begin
                if(rvalid_mem == 1) begin 
                    wen_rd <= 1;
                    // raddr_mem <= addr_tlb_temp + 16;
                    addr_rd <= addr_tlb_temp;
                    // addr_tlb_temp <= addr_tlb_temp + 16;
                    data_rd <= rdata_mem;
                    // set_rd <= set_tlb;
                    // coun;t <= count + 1
                    state <= IDLE;
                    raddr_mem <= 0;
                    ren_mem <= 0;
                end

                    // if(busy_wb) begin
                    //     // state <= WRITE;
                    //     // // waddr_mem <= addr_mem;
                    //     // addr_mem_temp <= addr_mem;
                    //     // bank_index <= 0;
                    // end else begin
                    //     state <= IDLE;
                    // end
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