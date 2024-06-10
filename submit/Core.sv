`include "ExceptStruct.vh"
`include "CSRStruct.vh"
`include "RegStruct.vh"
`include "TimerStruct.vh"
`include "Define.vh"
module Core (
    input wire clk,                       /* 时钟 */ 
    input wire rstn,                       /* 重置信号 */ 

    output wire [63:0] pc,                /* current pc */
    input wire [31:0] inst,               /* read inst from ram */

    output wire [63:0] address,           /* memory address */
    output wire we_mem,                   /* write enable */
    output wire [63:0] wdata_mem,         /* write data to memory */
    output wire [7:0] wmask_mem,          /* write enable for each byte */ 
    output wire re_mem,                   /* read enable */
    input wire [63:0] rdata_mem,          /* read data from memory */

    input wire if_stall,
    input wire mem_stall,
    output wire if_request,
    output wire switch_mode,

    output wire [63:0] iaddress,
    output wire        iren,
    input  wire [63:0] irdata,
    input  wire        immu_stall,

    output wire [63:0] daddress,
    output wire        dren,
    input  wire [63:0] drdata,
    input  wire        dmmu_stall,


    input TimerStruct::TimerPack time_out,

    output cosim_valid,
    output [63:0] cosim_pc,          /* current pc */
    output [31:0] cosim_inst,        /* current instruction */
    output [ 7:0] cosim_rs1_id,      /* rs1 id */
    output [63:0] cosim_rs1_data,    /* rs1 data */
    output [ 7:0] cosim_rs2_id,      /* rs2 id */
    output [63:0] cosim_rs2_data,    /* rs2 data */
    output [63:0] cosim_alu,         /* alu out */
    output [63:0] cosim_mem_addr,    /* memory address */
    output [ 3:0] cosim_mem_we,      /* memory write enable */
    output [63:0] cosim_mem_wdata,   /* memory write data */
    output [63:0] cosim_mem_rdata,   /* memory read data */
    output [ 3:0] cosim_rd_we,       /* rd write enable */
    output [ 7:0] cosim_rd_id,       /* rd id */
    output [63:0] cosim_rd_data,     /* rd data */
    output [ 3:0] cosim_br_taken,    /* branch taken? */
    output [63:0] cosim_npc,         /* next pc */
    output CSRStruct::CSRPack cosim_csr_info,
    output RegStruct::RegPack cosim_regs,

    output cosim_interrupt,
    output [63:0] cosim_cause
);
    import ExceptStruct::*;
    wire rst=~rstn;

    wire [63:0] IFpc;
    wire [63:0] IFnpc; 
    wire IDvalid;
    wire EXvalid;
    wire MEMvalid;
    wire WBvalid;
    wire PCstall;
    wire IFIDstall;
    wire IFIDflush;
    wire IDEXstall;
    wire IDEXflush;
    wire EXMEMstall;
    wire EXMEMflush;
    wire MEMWBstall;
    wire MEMWBflush;

    wire [63:0] pc_target_if;
    wire jump_if;

    wire isJ;
    assign isJ = (EXinst[6:0] == 7'b1100111) || (EXinst[6:0] == 7'b1101111);

    BranchPrediction branchprediction(
        .clk(clk),
        .rst(~rstn),
        .pc_if(IFpc),
        .jump_if(jump_if),
        .pc_target_if(pc_target_if),
        .pc_exe(EXpc),
        .pc_target_exe(EXalu_res),
        .jump_exe(EXnpc_sel && (br_taken || isJ)),
        .is_jump_exe(EXnpc_sel)
    );

    wire STALL;
    wire PCSTALL;
    wire valid;
    wire IFvalid;
    wire st;
    wire va;

    assign st = STALL;
    assign va = valid;

    assign PCSTALL = STALL || PCstall;
    assign IFvalid = valid && ~if_stall;
    
    PC pcset(
        .clk(clk),
        .rstn(rstn),
        .st(st),
        .va(va),
        .PCstall(PCSTALL),
        .npc(IFnpc),
        .pc(IFpc),
        .STALL(STALL),
        .valid(valid)
    );
    
    wire EXnpc_sel;
    wire [63:0] EXalu_res;
    wire [31:0] EXinst;
    wire br_taken;
    wire [63:0] pc_csr;


    NPC npcset(
        .npc_sel(EXnpc_sel),
        .br_taken(br_taken),
        .EXinst(EXinst),
        .alu_out(EXalu_res),
        .IFpc(IFpc),
        .switch_mode(switch_mode),
        .pc_csr(pc_csr),
        .npc(IFnpc)
    );

    wire [63:0] IDpc;
    wire [63:0] IDnpc;
    wire [31:0] IDinst;

    IFID ifid(
        .clk(clk),
        .rstn(rstn),
        .IFIDstall(IFIDstall),
        .IFIDflush(IFIDflush),
        .IFpc(IFpc),
        .IFnpc(IFnpc),
        .IFinst(inst),
        .IF_stall_if(IF_stall_if),
        .IF_stall_id(IF_stall_id),
        .IFvalid(IFvalid),
        .IDpc(IDpc),
        .IDnpc(IDnpc),
        .IDinst(IDinst),
        .IDvalid(IDvalid)
    );

    wire IDwe_reg;
    wire IDwe_mem;
    wire IDre_mem;
    wire IDnpc_sel;
    wire [2:0] immgen_op;
    wire [3:0] IDalu_op;
    wire [2:0] bralu_op;
    wire [1:0] IDalu_asel;
    wire [1:0] IDalu_bsel;
    wire [1:0] IDwb_sel;
    wire [2:0] IDmemdata_width;
    wire IDisi;
    wire [1:0] IDCSRalu_op;
    wire [1:0] csr_ret_ID;
    wire csr_we_ID;

    Control ctrl(
      .inst(IDinst),
      .decode({IDwe_reg,IDwe_mem,IDre_mem,IDnpc_sel,immgen_op[2:0],IDalu_op[3:0],bralu_op[2:0],IDalu_asel[1:0],IDalu_bsel[1:0],IDwb_sel[1:0],IDmemdata_width[2:0]}),
      .iscsr(csr_we_ID),
      .isi(IDisi),
      .CSRalu_op(IDCSRalu_op),
      .csr_ret(csr_ret_ID)
    );

    wire csr_we_WB;
    wire [11:0] csr_addr_WB;
    wire [63:0] csr_val_WB;
    wire [11:0] csr_addr_ID;
    wire [63:0] csr_val_ID;

    wire [1:0] csr_ret_WB;

    ExceptStruct::ExceptPack except_WB;

    wire [1:0] priv;

    assign csr_addr_ID = IDinst[31:20];

    wire [63:0] WBpc;

// satp
    wire [63:0] satp;

    CSRModule csrmodule(
        .clk(clk),
        .rst(rst),
        .csr_we_wb(csr_we_WB & ~switch_mode),
        .csr_addr_wb(csr_addr_WB),
        .csr_val_wb(csr_val_WB),
        .csr_addr_id(csr_addr_ID),
        .csr_val_id(csr_val_ID),

        .pc_wb(WBpc),
        .inst_wb(WBinst),
        .valid_wb(WBvalid),
        .time_out(time_out),
        .csr_ret_wb(csr_ret_WB),
        .csr_we_wb_temp(csr_we_WB),
        .except_wb(except_WB),

        .priv(priv),
        .switch_mode(switch_mode),
        .pc_csr(pc_csr),

        .cosim_interrupt(cosim_interrupt),
        .cosim_cause(cosim_cause),
        .cosim_csr_info(cosim_csr_info),

        .satp(satp)
    );

    ExceptStruct::ExceptPack except_ID='{except: 1'b0, epc:64'b0, ecause:64'b0, etval: 64'b0};
    ExceptStruct::ExceptPack except_EX;
    wire except_happen_id;
    wire is_ecall_id;
    wire is_ebreak_id;
    wire illegal_id;

    assign is_ecall_id = IDinst == `ECALL;
    assign is_ebreak_id = IDinst == `EBREAK;
    assign illegal_id = IDinst == 32'h2;

    IDExceptExamine id_except_examine(
        .clk(clk),
        .rst(rst),
        .stall(IDEXstall),
        .flush(IDEXflush),
        .pc_id(IDpc),
        .priv(priv),
        .is_ecall_id(is_ecall_id),
        .is_ebreak_id(is_ebreak_id),
        .illegal_id(illegal_id),
        .inst_id(IDinst),
        .valid_id(IDvalid),
        .except_id(except_ID),
        .except_exe(except_EX),
        .except_happen_id(except_happen_id)
    );

    wire [4:0] WBrd;
    wire [63:0] rd_data;
    wire [63:0] IDrs1;
    wire [63:0] IDrs2;
    wire [4:0] IDrs1addr;
    wire [4:0] IDrs2addr;
    wire WBwe_reg;

    assign IDrs1addr = IDinst[19:15];
    assign IDrs2addr = IDinst[24:20];

    Regs regs(
        .clk (clk),
        .rst (rst),
        .we  (WBwe_reg & ~switch_mode),
        .isi (IDisi),
        .read_addr_1 (IDrs1addr),
        .read_addr_2 (IDrs2addr),
        .write_addr (WBrd),
        .write_data (rd_data),
        .read_data_1 (IDrs1),
        .read_data_2 (IDrs2),
        .cosim_regs (cosim_regs)
    );

    wire [63:0] IDimm;

    Imm_Gen gen(
        .inst(IDinst),
        .immgen_op(immgen_op),
        .imm(IDimm)
    );
    
    wire EXwe_reg;
    wire EXwe_mem;
    wire EXre_mem;
    wire [2:0] EXimmgen_op;
    wire [3:0] EXalu_op;
    wire [2:0] EXbralu_op;
    wire [1:0] EXalu_asel;
    wire [1:0] EXalu_bsel;
    wire [1:0] EXwb_sel;
    wire [2:0] EXmemdata_width;
    wire [63:0] EXpc;
    wire [63:0] EXnpc;
    wire [4:0] EXrd;
    wire [63:0] EXrs1;
    wire [63:0] EXrs2;
    wire [63:0] EXimm;
    wire [1:0] csr_ret_EX;
    wire [63:0] csr_val_EX;
    wire csr_we_EX;
    wire [1:0] EXCSRalu_op;
    wire [11:0] csr_addr_EX;

    IDEX idex(
        .clk(clk),
        .rstn(rstn),
        .csr_addr_ID(csr_addr_ID),
        .IDCSRalu_op(IDCSRalu_op),
        .csr_we_ID(csr_we_ID),
        .csr_val_ID(csr_val_ID),
        .csr_ret_ID(csr_ret_ID),
        .IDvalid(IDvalid),
        .IDEXstall(IDEXstall),
        .IDEXflush(IDEXflush),
        .IDpc(IDpc),
        .IDnpc(IDnpc),
        .IDrd(IDinst[11:7]),
        .IDimm(IDimm),
        .IDrs1(IDrs1),
        .IDrs2(IDrs2),
        .IDinst(IDinst),
        .IDnpc_sel(IDnpc_sel),
        .IDwe_reg(IDwe_reg),
        .IDwe_mem(IDwe_mem),
        .IDre_mem(IDre_mem),
        .IDalu_op(IDalu_op),
        .IDbralu_op(bralu_op),
        .IDalu_asel(IDalu_asel),
        .IDalu_bsel(IDalu_bsel),
        .IDwb_sel(IDwb_sel),
        .IDmemdata_width(IDmemdata_width),
        .IF_stall_id(IF_stall_id),
        .IF_stall_exe(IF_stall_exe),
        .csr_addr_EX(csr_addr_EX),
        .EXCSRalu_op(EXCSRalu_op),
        .csr_we_EX(csr_we_EX),
        .csr_val_EX(csr_val_EX),
        .csr_ret_EX(csr_ret_EX),
        .EXvalid(EXvalid),
        .EXnpc_sel(EXnpc_sel),
        .EXwe_reg(EXwe_reg),
        .EXwe_mem(EXwe_mem),
        .EXre_mem(EXre_mem),
        .EXalu_op(EXalu_op),
        .EXbralu_op(EXbralu_op),
        .EXalu_asel(EXalu_asel),
        .EXalu_bsel(EXalu_bsel),
        .EXwb_sel(EXwb_sel), 
        .EXmemdata_width(EXmemdata_width),
        .EXpc(EXpc),
        .EXnpc(EXnpc),
        .EXrd(EXrd),
        .EXrs1(EXrs1),
        .EXrs2(EXrs2),
        .EXimm(EXimm),
        .EXinst(EXinst)
    );

    wire [1:0] rs1_forwarding;
    wire [1:0] rs2_forwarding;
    wire [4:0] MEMrd;
    wire MEMwe_reg;

    Forwarding forwarding(
        .MEMwe_reg(MEMwe_reg),
        .WBwe_reg(WBwe_reg),
        .EXinst(EXinst),
        .MEMrd(MEMrd),
        .WBrd(WBrd),
        .rs1_forwarding(rs1_forwarding),
        .rs2_forwarding(rs2_forwarding)
    );
    
    wire [63:0] MEMalu_res;

    Branch_Comp cmp(
        .rs1(EXrs1),
        .rs2(EXrs2),
        .rs1_forwarding(rs1_forwarding),
        .rs2_forwarding(rs2_forwarding),
        .MEMalu_res(MEMalu_res),
        .rd_data(rd_data),
        .bralu_op(EXbralu_op),
        .br_taken(br_taken)
    );

    wire [63:0] alu_a;
    wire [63:0] alu_b;
    wire isBRANCH = EXinst[6:0] == 7'b1100011;
    wire isLUI = EXinst[6:0] == 7'b0110111;

    ALU_Sel sel(
        .alu_asel(EXalu_asel),
        .alu_bsel(EXalu_bsel),
        .rs1_forwarding(rs1_forwarding),
        .rs2_forwarding(rs2_forwarding),
        .MEMalu_res(MEMalu_res),
        .rd_data(rd_data),
        .rs1(EXrs1),
        .pc(EXpc),
        .rs2(EXrs2),
        .imm(EXimm),
        .isBRANCH(isBRANCH),
        .isLUI(isLUI),
        .A(alu_a),
        .B(alu_b)
    );

    ALU alu(
        .a (alu_a),
        .b (alu_b),
        .alu_op (EXalu_op),
        .csr_we_EX(csr_we_EX),
        .csr_val_EX(csr_val_EX),
        .res (EXalu_res)
    );

    wire [63:0] _csr_val_EX;

    CSRALU csralu(
        .csr_val_EX(csr_val_EX),
        .rs1_data(alu_a),
        .CSRalu_op(EXCSRalu_op),
        .CSRres(_csr_val_EX)
    );

    wire [7:0] mem_mask;

    wire [63:0] MEMrs1;
    wire [63:0] MEMrs2;
    wire [63:0] MEMpc;
    wire [63:0] MEMnpc;
    wire [63:0] MEMmem_wdata;
    wire MEMnpc_sel;
    wire [1:0] MEMwb_sel;
    wire MEMwe_mem;
    wire [2:0] MEMmemdata_width;
    wire [31:0] MEMinst;
    wire MEMbr_taken;
    wire MEMre_mem;
    ExceptStruct::ExceptPack except_MEM;
    wire [1:0] csr_ret_MEM;
    wire csr_we_MEM;
    wire [63:0] csr_val_MEM;
    wire [11:0] csr_addr_MEM;

    EXMEM exmem(
        .clk(clk),
        .rstn(rstn),
        .csr_addr_EX(csr_addr_EX),
        .csr_val_EX(_csr_val_EX),
        .csr_we_EX(csr_we_EX),
        .csr_ret_EX(csr_ret_EX),
        .except_exe(except_EX),
        .EXvalid(EXvalid),
        .EXMEMstall(EXMEMstall),
        .EXMEMflush(EXMEMflush),
        .br_taken(br_taken),
        .EXpc(EXpc),
        .EXnpc(EXnpc),
        .EXnpc_sel(EXnpc_sel),
        .EXwe_reg(EXwe_reg),
        .EXwb_sel(EXwb_sel),
        .EXwe_mem(EXwe_mem),
        .EXre_mem(EXre_mem),
        .EXmemdata_width(EXmemdata_width),
        .EXrd(EXrd),
        .EXrs1(EXrs1),
        .EXrs2(EXrs2),
        .EXalu_res(EXalu_res),
        .EXinst(EXinst),
        .csr_addr_MEM(csr_addr_MEM),
        .csr_val_MEM(csr_val_MEM),
        .csr_we_MEM(csr_we_MEM),
        .except_mem(except_MEM),
        .csr_ret_MEM(csr_ret_MEM),
        .MEMvalid(MEMvalid),
        .MEMbr_taken(MEMbr_taken),
        .MEMrs1(MEMrs1),
        .MEMrs2(MEMrs2),
        .MEMpc(MEMpc),
        .MEMnpc(MEMnpc),
        .MEMrd(MEMrd),
        .MEMalu_res(MEMalu_res),
        .MEMnpc_sel(MEMnpc_sel),
        .MEMwe_reg(MEMwe_reg),
        .MEMwb_sel(MEMwb_sel),
        .MEMwe_mem(MEMwe_mem),
        .MEMre_mem(MEMre_mem),
        .MEMmemdata_width(MEMmemdata_width),
        .MEMinst(MEMinst)
    );

    MaskGen maskgen(
        .memdata_width(MEMmemdata_width),
        .alu_out(MEMalu_res[2:0]),
        .rs2_data(MEMrs2),
        .mask_out(mem_mask),
        .rw_wdata(MEMmem_wdata)
    );
    
    wire [31:0] WBinst;

// paddr_valid
    Race_Control race_control(
        .if_stall(if_stall | (!ipaddr_valid & (~IF_stall_exe | switch_mode))),
        .mem_stall(mem_stall | (!dpaddr_valid & (MEMwe_mem | MEMre_mem))),
        .switch_mode(switch_mode),
        .isJ(isJ),
        .br_taken(br_taken),
        .EXnpc_sel(EXnpc_sel),
        .PCstall(PCstall),
        .IFIDstall(IFIDstall),
        .IFIDflush(IFIDflush),
        .IDEXstall(IDEXstall),
        .IDEXflush(IDEXflush),
        .EXMEMstall(EXMEMstall),
        .EXMEMflush(EXMEMflush),
        .MEMWBstall(MEMWBstall),
        .MEMWBflush(MEMWBflush)
    );

    wire [63:0] rdata_mem_delay;
    wire IF_stall_if;
    wire IF_stall_id;
    wire IF_stall_exe;

    FuckingModule fuckingmodule(
        .clk(clk),
        .rstn(rstn),
        .PCstall(PCstall),
        .rdata_mem(rdata_mem),
        .IF_stall(IF_stall_if),
        .rdata_mem_delay(rdata_mem_delay)
    );

    wire [63:0] MEMmem_truncout;
    wire [63:0] rdata_mem_reg;
    wire is_mmio;

    assign is_mmio=(`MTIME_BASE==MEMalu_res)|
        (`MTIMECMP_BASE==MEMalu_res)|
        (`DISP_BASE==MEMalu_res)|
        ((`UART_BASE==MEMalu_res)&((`UART_BASE+`UART_LEN)==MEMalu_res));

    assign rdata_mem_reg = is_mmio? rdata_mem_delay:rdata_mem;

    Data_Trunc datatrunc(
        .alu_res(MEMalu_res),
        .memdata_width(MEMmemdata_width),
        .rdata(rdata_mem_reg),
        .shift(MEMalu_res[2:0]),
        .rd_data(MEMmem_truncout)
    );
    
    wire WBwe_mem;
    wire [1:0] WBwb_sel;
    wire [63:0] WBnpc;
    wire [63:0] WBalu_res;
    wire [63:0] WBmem_out;
    wire [63:0] WBrs1;
    wire [63:0] WBrs2;
    wire [63:0] WBmem_wdata;
    wire [2:0] WBmemdata_width;
    wire WBbr_taken;

    MEMWB memwb(
        .clk(clk),
        .rstn(rstn),
        .csr_addr_MEM(csr_addr_MEM),
        .csr_val_MEM(csr_val_MEM),
        .csr_we_MEM(csr_we_MEM),
        .csr_ret_MEM(csr_ret_MEM),
        .except_mem(except_MEM),
        .MEMvalid(MEMvalid),
        .MEMWBstall(MEMWBstall),
        .MEMWBflush(MEMWBflush),
        .MEMbr_taken(MEMbr_taken),
        .MEMrs1(MEMrs1),
        .MEMrs2(MEMrs2),
        .MEMwe_reg(MEMwe_reg),
        .MEMwe_mem(MEMwe_mem),
        .MEMwb_sel(MEMwb_sel),
        .MEMmem_wdata(MEMmem_wdata),
        .MEMalu_res(MEMalu_res),
        .MEMmem_truncout(MEMmem_truncout),
        .MEMpc(MEMpc),
        .MEMnpc(MEMnpc),
        .MEMrd(MEMrd),
        .MEMinst(MEMinst),
        .csr_addr_WB(csr_addr_WB),
        .csr_val_WB(csr_val_WB),
        .csr_we_WB(csr_we_WB),
        .except_wb(except_WB),
        .csr_ret_WB(csr_ret_WB),
        .WBvalid(WBvalid),
        .WBbr_taken(WBbr_taken),
        .WBmem_wdata(WBmem_wdata),
        .WBrs1(WBrs1),
        .WBrs2(WBrs2),
        .WBwe_reg(WBwe_reg),
        .WBwe_mem(WBwe_mem),
        .WBwb_sel(WBwb_sel),
        .WBpc(WBpc),
        .WBnpc(WBnpc),
        .WBalu_res(WBalu_res),
        .WBmem_out(WBmem_out),
        .WBrd(WBrd),
        .WBinst(WBinst)
    );

    WbtoRegs wb2reg(
        .wb_sel(WBwb_sel),
        .alu_res(WBalu_res),
        .mem_data(WBmem_out),
        .npc(WBpc+4),
        .rd_data(rd_data)
    );
    
    //assign pc; //= IFpc; // to be change to physical
    //assign address;// = MEMalu_res;
    assign we_mem = MEMwe_mem & dpaddr_valid;
    assign wdata_mem = MEMmem_wdata;
    assign wmask_mem = mem_mask;
    assign re_mem = MEMre_mem & dpaddr_valid;
    // ipaddr_valid
    assign if_request = (~IF_stall_exe | switch_mode) & ipaddr_valid;


    assign cosim_valid = WBvalid&~cosim_interrupt;
    // assign cosim_valid = WBvalid;
    assign cosim_pc = WBpc;
    assign cosim_inst = WBinst;
    assign cosim_rs1_id= {3'b0, WBinst[19:15]};
    assign cosim_rs1_data = WBrs1;
    assign cosim_rs2_id = {3'b0,WBinst[24:20]};
    assign cosim_rs2_data = WBrs2;
    assign cosim_alu = WBalu_res;
    assign cosim_mem_addr = WBalu_res;
    assign cosim_mem_we = {3'b0, WBwe_mem};
    assign cosim_mem_wdata = WBmem_wdata;
    assign cosim_mem_rdata = WBmem_out;
    assign cosim_rd_we = {3'b0, WBwe_reg};
    assign cosim_rd_id = {3'b0, WBinst[11:7]};
    assign cosim_rd_data = rd_data;
    assign cosim_br_taken ={3'b0,WBbr_taken};
    assign cosim_npc = WBnpc;

    ////////////////////////////////////////////////

    // assign cosim_valid=valid_wb&~cosim_interrupt;
    // assign cosim_pc=pc_wb;      
    // assign cosim_inst=inst_wb;
    // assign cosim_rd_we={3'b0,we_reg_wb};
    // assign cosim_rd_id={3'b0,rd_wb}; 
    // assign cosim_rd_data=wb_val_wb;  

    // assign cosim_rs1_id={3'b0,rs1_exe};
    // assign cosim_rs1_data=read_data_1_new_exe;
    // assign cosim_rs2_id={3'b0,rs2_exe};
    // assign cosim_rs2_data=read_data_2_new_exe;
    // assign cosim_alu=alu_res_exe;

    // assign cosim_mem_addr=address;
    // assign cosim_mem_we={3'b0,we_mem};
    // assign cosim_mem_wdata=data_package;
    // assign cosim_mem_rdata=data_trunc;

    // assign cosim_br_taken={3'b0,npc_sel_exe};
    // assign cosim_npc=pc_4_if;


    // Xpart mmu part

    wire        ipaddr_valid;
    wire        dpaddr_valid;



    mmu immu (
        .clk(clk),
        .rst(rstn),
        .vaddr(IFpc),
        .paddr(pc),
        .addr(iaddress),
        .ren(iren),
        .rdata(irdata),
        .mmu_stall(immu_stall),
        .mmu_signal((~IF_stall_exe | switch_mode)),
        .paddr_valid(ipaddr_valid),
        .satp(satp)
    );

    mmu dmmu (
        .clk(clk),
        .rst(rstn),
        .vaddr(MEMalu_res),
        .paddr(address),
        .addr(daddress),
        .ren(dren),
        .rdata(drdata),
        .mmu_stall(dmmu_stall),
        .mmu_signal(MEMwe_mem | MEMre_mem),
        .paddr_valid(dpaddr_valid),
        .satp(satp)
    );


endmodule