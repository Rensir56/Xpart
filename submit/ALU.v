module ALU (
  input  [63:0] a, //a操作�?
  input  [63:0] b, //b操作�?
  input  [3:0]  alu_op, //操作方法
  input  csr_we_EX,
  input  [63:0] csr_val_EX,
  output [63:0] res//操作的结�?

);
  parameter   ADD  = 4'b0000,
              SUB  = 4'b0001,
              SLL  = 4'b0111,
              SLT  = 4'b0101,
              SLTU = 4'b0110,
              XOR  = 4'b0100,
              SRL  = 4'b1000,
              SRA  = 4'b1001,
              OR   = 4'b0011,
              AND  = 4'b0010,
              ADDW = 4'b1010,
              SUBW = 4'b1011,
              SLLW = 4'b1100,
              SRLW = 4'b1101,
              SRAW = 4'b1110;
  reg [63:0]result;
  assign res = (csr_we_EX == 0)? result : csr_val_EX;
  integer i;
  reg [7:0]imm_shi;
  reg [63:0]b_down;
  always @(*) begin
    imm_shi = b[7:0];
    b_down = b;
      case (alu_op)
          4'b1111 : result = a + b; 
          ADD:  result = a + b; //加法
          SUB:  result = a - b; //减法
          SLL:  begin
            if(b[63] == 0) result = a << b;              
            else result = $signed(a) << (32-(~b+1)%32);
          end //左移�?
          SLT:  begin //针对有符号数的小于操作，若a < b 则结果为1，否则为0，其中a，b都是有符号数
            if(a[63] == b[63]) begin
              result = (a < b)? {63'b0,~a[63]} : {63'b0,a[63]}; //如果两�?�符号位相等
            end
            else if(a[63] == 0&&b[63] == 1) result = 0; //如果两�?�符号位不等则负数小
            else if(a[63] == 1&&b[63] == 0) result = {63'b0,1'b1};
            else result = 0;
          end
          SLTU: result = (a < b)? 1: 0; //针对无符号数的小于操�?
          XOR:  result = a ^ b; //异或
          SRL:  begin 
            if(b[63] == 0) result = a >> b;              
            else result = $signed(a) >> (32-(~b+1)%32);
          end 
          SRA:begin
          if(b[63] == 0) result = $signed(a) >>> imm_shi;              
            else result = $signed(a) >>> (32-(~b+1)%32);
          end
          OR:   result = a|b; //�?
          AND:  result = a&b; //�?
          ADDW : begin
            result = a+b;
            result = {{32{result[31]}},result[31:0]};
          end
          SUBW : begin
            result = a-b;
            result = {{32{result[31]}},result[31:0]};
          end
          SLLW : begin
            result = {{32{a[31]}},a[31:0]};
            if(b[63] == 0) result = a << b;
            else result = $signed(result) << (32-(~b+1)%32);
            result = {{32{result[31]}},result[31:0]};
          end
          SRLW : begin
            result = {32'b0,a[31:0]};
            if(b[63] == 0) result = result >> b;
            else result = $signed(result) >> (32-(~b+1)%32);
              result = {{32{result[31]}},result[31:0]};
            end
          
          SRAW : begin
            result = {{32{a[31]}},a[31:0]};
            if(b[63] == 0) result = $signed (result) >>> imm_shi ;
            else result = $signed(result) >>> (32-(~b+1)%32);
            result = {{32{result[31]}},result[31:0]};
          end        
          // TODO:
          default: result = a; //如果都不是，结果�?0
      endcase
  end
endmodule
