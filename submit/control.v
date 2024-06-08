`define MATHr 7'b0110011
`define MATHi 7'b0010011
`define MATHWi 7'b0011011
`define MATHWr 7'b0111011
`define JALr 7'b1100111
`define JAL 7'b1101111
`define BRANCH 7'b1100011
`define LUI 7'b0110111
`define AUIPC 7'b0010111
`define SW 7'b0100011
`define LW 7'b0000011
`define CSR 7'b1110011

module Control(
  input [31:0] inst,
  output wire [22:0] decode,
  output reg iscsr,
  output reg isi,
  output reg [1:0] CSRalu_op,
  output reg [1:0] csr_ret
);
  reg we_reg, we_mem, re_mem, npc_sel;
  reg [2:0] immgen_op;
  reg [3:0] alu_op;
  reg [2:0] bralu_op;
  reg [1:0] alu_asel, alu_bsel, wb_sel; 
  reg [2:0] memdata_width;

  wire [6:0] opcode = inst[6:0];
  wire [2:0] funct3 = inst[14:12];
  wire funct7_5 = inst[30] ;
  
  reg isR;
  reg isI;
  reg isWI;
  reg isWR;
  reg isJAL;
  reg isJALR;
  reg isBRANCH;
  reg isLUI;
  reg isAUIPC;
  reg isSW;
  reg isLW;
  reg isCSR;

  always @*begin
    isR = (opcode == `MATHr);
    isI = (opcode == `MATHi);
    isWI = (opcode == `MATHWi);
    isWR = (opcode == `MATHWr);
    isJAL = (opcode == `JAL);
    isJALR = (opcode == `JALr);
    isBRANCH = (opcode == `BRANCH);
    isLUI = (opcode == `LUI);
    isAUIPC = (opcode == `AUIPC);
    isSW = (opcode == `SW);
    isLW = (opcode == `LW);
    isCSR = (opcode == `CSR);
  end

  initial begin
      we_reg = 0;
      we_mem = 0;
      npc_sel = 0;
      immgen_op = 0;
      alu_op = 0;
      bralu_op = 0;
      alu_asel = 0;
      alu_bsel = 0;
      wb_sel = 0;
      memdata_width = 0;
  end
  
  always @(*) begin
    iscsr = isCSR;

    we_reg = !(isBRANCH || isSW);

    we_mem = isSW;

    re_mem = isLW;

    npc_sel = isBRANCH || isJAL || isJALR;

    immgen_op = (isI || isWI || isLW || isJALR)? 3'b001:
                isSW ? 3'b010:
                isBRANCH ? 3'b011:
                (isLUI || isAUIPC)? 3'b100:
                isJAL ? 3'b101: 3'b000;
      
    isi = isCSR && (funct3 == 3'b101 || funct3 == 3'b110 || funct3 == 3'b111);

    CSRalu_op = isCSR?
                ((funct3 == 3'b001 || funct3 == 3'b101)? 2'b01 :
                 (funct3 == 3'b010 || funct3 == 3'b110)? 2'b10 :
                 (funct3 == 3'b011 || funct3 == 3'b111)? 2'b11 : 2'b00) : 2'b00;

    csr_ret = (inst == 32'h30200073) ? 2'b10 :
              (inst == 32'h10200073) ? 2'b01 : 2'b00;

    case (opcode)
      7'b0110011: begin  //R鍨嬫寚浠�
        case (funct3)
            3'b000: alu_op = funct7_5 == 0 ? 4'b0000 : 4'b0001; //ADD鍜孲UB
            3'b001: alu_op = 4'b0111; //SLL
            3'b010: alu_op = 4'b0101; //SLT
            3'b011: alu_op = 4'b0110; //SLTU
            3'b100: alu_op = 4'b0100; //XOR
            3'b101: alu_op = funct7_5 == 0 ? 4'b1000 : 4'b1001; // SRL鍜孲RA
            3'b110: alu_op = 4'b0011; //OR
            3'b111: alu_op = 4'b0010; //AND
            default: alu_op = 4'b1111;
        endcase
      end
      7'b0111011:begin  //Rw鍨嬫寚浠�
        case (funct3)
            3'b000: alu_op = funct7_5 == 0 ? 4'b1010 : 4'b1011; //ADDW鍜孲UBW
            3'b001: alu_op = 4'b1100;  //SLLW
            3'b101: alu_op = funct7_5 == 0 ? 4'b1101 : 4'b1110; //SRLW鍜孲RAW
            default: alu_op = 4'b1111;
        endcase
      end
      7'b0010011: begin //I鍨嬫寚浠�
        case (funct3)
            3'b000: alu_op = 4'b0000; //ADD
            3'b001: alu_op = 4'b0111; //SLL
            3'b010: alu_op = 4'b0101; //SLT
            3'b011: alu_op = 4'b0110; //SLTU
            3'b100: alu_op = 4'b0100; //XOR
            3'b101: alu_op = funct7_5 == 0 ? 4'b1000 : 4'b1001; // SRL鍜孲RA
            3'b110: alu_op = 4'b0011; //OR
            3'b111: alu_op = 4'b0010; //AND
            default: alu_op = 4'b1111;
        endcase
      end
      7'b0011011: begin //Iw鍨嬫寚浠�
        case(funct3)
            3'b000:alu_op=4'b1010;
            3'b001:alu_op=4'b1100;
            3'b101:alu_op=(funct7_5==0)? 4'b1101:4'b1110;
            default: alu_op = 4'b1111;
        endcase
      end
      default: alu_op = 4'b0000;
    endcase

    bralu_op = (isBRANCH == 1)? 
      (funct3 == 3'b000 ? 3'b001 : 
      funct3 == 3'b001 ? 3'b010 : 
      funct3 == 3'b100 ? 3'b011 : 
      funct3 == 3'b101 ? 3'b100 : 
      funct3 == 3'b110 ? 3'b101 : 
      funct3 == 3'b111 ? 3'b110 : 3'b000):3'b000;

    alu_asel = (isR || isWR || isI || isWI || isLW || isSW || isJALR || isCSR)? 2'b01:
               (isBRANCH || isJAL || isAUIPC)? 2'b10:
               (isLUI)? 2'b00:2'b00;

    alu_bsel = (isR || isWR)? 2'b01:
               (isI || isWI || isLW || isSW || isJALR || isBRANCH || isJAL || isAUIPC || isLUI)? 2'b10 : 2'b00;

    wb_sel = (isR || isWR || isI || isWI || isBRANCH || isAUIPC || isLUI || isCSR)? 2'b01:
             isLW ? 2'b10:
             (isJAL || isJALR)? 2'b11: 2'b00;

    if(isSW)begin
      case (funct3)
        3'b011: memdata_width = 3'b001;
        3'b010: memdata_width = 3'b010;
        3'b001: memdata_width = 3'b011;
        3'b000: memdata_width = 3'b100;
        default: memdata_width = 3'b000;
      endcase
    end
    if(isLW)begin
      case(funct3) 
          3'b000: memdata_width = 3'b100; //LB 
          3'b001: memdata_width = 3'b011; //LH 
          3'b010: memdata_width = 3'b010; //LW 
          3'b011: memdata_width = 3'b001; //LD 
          3'b100: memdata_width = 3'b111; //LUB 
          3'b101: memdata_width = 3'b110; //LUH 
          3'b110: memdata_width = 3'b101; //LUW 
          default: memdata_width = 3'b000; 
      endcase
    end
  end

  assign decode = { we_reg, we_mem, re_mem, npc_sel, immgen_op, alu_op, bralu_op, alu_asel, alu_bsel, wb_sel, memdata_width };
endmodule