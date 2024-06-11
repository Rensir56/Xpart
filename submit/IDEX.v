module IDEX(    
    input clk, 
    input rstn,
    input [11:0] csr_addr_ID,
    input [1:0] IDCSRalu_op,
    input csr_we_ID,
    input [63:0] csr_val_ID,
    input [1:0] csr_ret_ID,
    input IDvalid,
    input IDEXstall,
    input IDEXflush,
    input [63:0] IDpc,
    input [63:0] IDnpc,
    input [4:0] IDrd,
    input [63:0] IDimm,
    // input [63:0] IDrs1,
    // input [63:0] IDrs2,
    input [31:0] IDinst,
    input IDnpc_sel,
    input IDwe_reg,
    input IDwe_mem,
    input IDre_mem,
    input [3:0] IDalu_op,
    input [2:0] IDbralu_op,
    input [1:0] IDalu_asel,
    input [1:0] IDalu_bsel,
    input [1:0] IDwb_sel,
    input [2:0] IDmemdata_width,
    input IF_stall_id,
    output reg IF_stall_exe,
    output reg [11:0] csr_addr_EX,
    output reg [1:0] EXCSRalu_op,
    output reg csr_we_EX,
    output reg [63:0] csr_val_EX,
    output reg [1:0] csr_ret_EX,
    output reg EXvalid,
    output reg EXnpc_sel,
    output reg EXwe_reg,
    output reg EXwe_mem,
    output reg EXre_mem,
    output reg [3:0] EXalu_op,
    output reg [2:0] EXbralu_op,
    output reg [1:0] EXalu_asel,
    output reg [1:0] EXalu_bsel,
    output reg [1:0] EXwb_sel,
    output reg [2:0] EXmemdata_width,
    output reg [63:0] EXpc,
    output reg [63:0] EXnpc,
    output reg [4:0] EXrd,
    output reg [63:0] EXimm,
    output reg [31:0] EXinst
);   
    always @(posedge clk) begin
        if(rstn == 0 || IDEXflush == 1)begin
            csr_addr_EX <= 0;
            EXCSRalu_op <= 0;
            csr_we_EX <= 0;
            csr_val_EX <= 0;
            csr_ret_EX <= 0;
            EXvalid <= 0;
            EXnpc_sel <= 0;
            EXwe_reg <= 0;
            EXwe_mem <= 0;
            EXalu_op <= 0;
            EXbralu_op <= 0;
            EXalu_asel <= 0;
            EXalu_bsel <= 0;
            EXwb_sel <= 0; 
            EXmemdata_width <= 0;
            EXpc <= 0;
            EXnpc <= 0;
            EXrd <= 0;
            EXimm <= 0;
            EXinst <= 0;
            EXre_mem <= 0;
            IF_stall_exe <= 0;
        end else if(IDEXstall == 0)begin
            csr_addr_EX <= csr_addr_ID;
            EXCSRalu_op <= IDCSRalu_op;
            csr_we_EX <= csr_we_ID;
            csr_val_EX <= csr_val_ID;
            csr_ret_EX <= csr_ret_ID;
            EXre_mem <= IDre_mem;
            EXvalid <= IDvalid;
            EXnpc_sel <= IDnpc_sel;
            EXwe_reg <= IDwe_reg;
            EXwe_mem <= IDwe_mem;
            EXalu_op <= IDalu_op;
            EXalu_asel <= IDalu_asel;
            EXalu_bsel <= IDalu_bsel;
            EXwb_sel <= IDwb_sel;
            EXbralu_op <= IDbralu_op;
            EXmemdata_width <= IDmemdata_width;
            EXpc <= IDpc;
            EXnpc <= IDnpc;
            EXrd <= IDrd;
            EXimm <= IDimm;
            EXinst <= IDinst;
            IF_stall_exe <= IF_stall_id;
        end
    end
endmodule    