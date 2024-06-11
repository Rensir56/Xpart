module NPC(    
    input jump_exe, 
    input [63:0] alu_out,   
    input [63:0] IFpc, 
    input switch_mode,
    input [63:0] pc_csr,
    output reg [63:0] npc    
);   

    always @(*) begin
        if(switch_mode) begin
            npc = pc_csr;
        end
        else if (jump_exe) begin
            npc = alu_out;
        end
        else begin
            npc = IFpc + 4;
        end
    end
endmodule    