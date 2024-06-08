`include "ExceptStruct.vh"
module MEMWB(    
    input clk, 
    input rstn,
    input [11:0] csr_addr_MEM,
    input [63:0] csr_val_MEM,
    input csr_we_MEM,
    input [1:0] csr_ret_MEM,
    input ExceptStruct::ExceptPack except_mem,
    input MEMvalid,
    input MEMWBstall,
    input MEMWBflush,
    input MEMbr_taken,
    input [63:0] MEMrs1,
    input [63:0] MEMrs2,
    input MEMwe_reg,
    input MEMwe_mem,
    input [1:0] MEMwb_sel,
    input [63:0] MEMmem_wdata,
    input [63:0] MEMalu_res,
    input [63:0] MEMmem_truncout,
    input [63:0] MEMpc,
    input [63:0] MEMnpc,
    input [4:0] MEMrd,
    input [31:0] MEMinst,
    output reg [11:0] csr_addr_WB,
    output reg [63:0] csr_val_WB,
    output reg csr_we_WB,
    output ExceptStruct::ExceptPack except_wb,
    output reg [1:0] csr_ret_WB,
    output reg WBvalid,
    output reg WBbr_taken,
    output reg [63:0] WBmem_wdata,
    output reg [63:0] WBrs1,
    output reg [63:0] WBrs2,
    output reg WBwe_reg,
    output reg WBwe_mem,
    output reg [1:0] WBwb_sel,
    output reg [63:0] WBpc,
    output reg [63:0] WBnpc,
    output reg [63:0] WBalu_res,
    output reg [63:0] WBmem_out,
    output reg [4:0] WBrd,
    output reg [31:0] WBinst
);   
    always @(posedge clk) begin
        if(rstn == 0 || MEMWBflush == 1)begin
            csr_addr_WB <= 0;
            csr_val_WB <= 0;
            csr_we_WB <= 0;
            csr_ret_WB <= 0;
            except_wb <= '{except: 1'b0, epc:64'b0, ecause:64'b0, etval: 64'b0};
            WBvalid <= 0;
            WBbr_taken <= 0;
            WBmem_wdata <= 0;
            WBrs1 <= 0;
            WBrs2 <= 0;
            WBwe_reg <= 0;
            WBwe_mem <= 0;
            WBwb_sel <= 0;
            WBpc <= 0;
            WBnpc <= 0;
            WBalu_res <= 0;
            WBmem_out <= 0;
            WBrd <= 0;
            WBinst <= 0;
        end else if (MEMWBstall == 0) begin
            csr_addr_WB <= csr_addr_MEM;
            csr_val_WB <= csr_val_MEM;
            csr_we_WB <= csr_we_MEM;
            csr_ret_WB <= csr_ret_MEM;
            except_wb <= except_mem;
            WBvalid <= MEMvalid;
            WBrs1 <= MEMrs1;
            WBrs2 <= MEMrs2;
            WBwe_reg <= MEMwe_reg;
            WBwb_sel <= MEMwb_sel;
            WBpc <= MEMpc;
            WBnpc <= MEMnpc;
            WBalu_res <= MEMalu_res;
            WBmem_out <= MEMmem_truncout;
            WBrd <= MEMrd;
            WBinst <= MEMinst;
            WBwe_mem <= MEMwe_mem;
            WBbr_taken <= MEMbr_taken;
            WBmem_wdata <= MEMmem_wdata;
        end
    end
endmodule    