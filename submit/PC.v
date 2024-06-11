module PC(    
    input clk,    
    input rstn, 
    input PCstall, 
    input jump_exe,
    // input br_taken, 
    input [63:0] npc,   
    output reg [63:0] pc
);  
    reg [63:0] pc_next = 0;

    always @(posedge clk or negedge rstn) begin
        if (rstn == 0) begin
          pc <= 0; 
        end
        // else if(PCstall == 0 || jump_exe) begin
        else if(PCstall == 0) begin
          pc <= npc;
        end
  end
endmodule    