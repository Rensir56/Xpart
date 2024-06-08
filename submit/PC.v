module PC(    
    input clk,    
    input rstn, 
    input st,
    input va, 
    input PCstall, 
    // input br_taken, 
    input [63:0] npc,   
    output reg [63:0] pc,
    output reg STALL,
    output reg valid
);  
    reg [63:0] pc_next = 0;

    always @(posedge clk or negedge rstn) begin
        if (rstn == 0) begin
          pc <= 0; 
          STALL <= 1;
          valid <= 0;
        end
        else if (st == 1 || va == 0) begin
          STALL <= 0;
          valid <= 1;
        end
        else if(PCstall == 0) begin
          pc <= npc;
        end
  end
endmodule    