`include "ExceptStruct.vh"
module EXMEM(    
    input clk, 
    input rstn,
    input [11:0] csr_addr_EX,
    input [63:0] csr_val_EX,
    input csr_we_EX,
    input [1:0] csr_ret_EX,
    input ExceptStruct::ExceptPack except_exe,
    input EXvalid,
    input EXMEMstall,
    input EXMEMflush,
    input br_taken,
    input [63:0] EXpc,
    input [63:0] EXnpc,
    input EXnpc_sel,
    input EXwe_reg,
    input [1:0] EXwb_sel,
    input EXwe_mem,
    input EXre_mem,
    input [2:0] EXmemdata_width,
    input [4:0] EXrd,
    input [63:0] EXrs1,
    input [63:0] EXrs2,
    input [63:0] EXalu_res,
    input [31:0] EXinst,
    output reg [11:0] csr_addr_MEM,
    output reg [63:0] csr_val_MEM,
    output reg csr_we_MEM,
    output ExceptStruct::ExceptPack except_mem,
    output reg [1:0] csr_ret_MEM,
    output reg MEMvalid,
    output reg MEMbr_taken,
    output reg [63:0] MEMrs1,
    output reg [63:0] MEMrs2,
    output reg [63:0] MEMpc,
    output reg [63:0] MEMnpc,
    output reg [4:0] MEMrd,
    output reg [63:0] MEMalu_res,
    output reg MEMnpc_sel,
    output reg MEMwe_reg,
    output reg [1:0] MEMwb_sel,
    output reg MEMwe_mem,
    output reg MEMre_mem,
    output reg [2:0] MEMmemdata_width, 
    output reg [31:0] MEMinst
);   
    always @(posedge clk) begin
        if(rstn == 0 || EXMEMflush == 1)begin
            csr_addr_MEM <= 0;
            csr_val_MEM <= 0;
            csr_we_MEM <= 0;
            csr_ret_MEM <= 0;
            except_mem <= '{except: 1'b0, epc:64'b0, ecause:64'b0, etval: 64'b0};
            MEMre_mem <= 0;
            MEMvalid <= 0;
            MEMbr_taken <= 0;
            MEMrs1 <= 0;
            MEMrs2 <= 0;
            MEMpc <= 0;
            MEMnpc <= 0;
            MEMrd <= 0;
            MEMalu_res <= 0;
            MEMnpc_sel <= 0;
            MEMwe_reg <= 0;
            MEMwb_sel <= 0;
            MEMwe_mem <= 0;
            MEMmemdata_width <= 0;
            MEMinst <= 0;  
        end else if (EXMEMstall == 0) begin
            csr_addr_MEM <= csr_addr_EX;
            csr_val_MEM <= csr_val_EX;
            csr_we_MEM <= csr_we_EX;
            csr_ret_MEM <= csr_ret_EX;
            except_mem <= except_exe;
            MEMre_mem <= EXre_mem;
            MEMrs1 <= EXrs1;
            MEMrs2 <= EXrs2;
            MEMpc <= EXpc;
            MEMnpc <= EXnpc;
            MEMalu_res <= EXalu_res;
            MEMnpc_sel <= EXnpc_sel;
            MEMwe_reg <= EXwe_reg;
            MEMwb_sel <= EXwb_sel;
            MEMwe_mem <= EXwe_mem;
            MEMmemdata_width <= EXmemdata_width;
            MEMinst <= EXinst;
            MEMrd <= EXrd;
            MEMbr_taken <= br_taken;
            MEMvalid <= EXvalid;
        end
    end
endmodule    