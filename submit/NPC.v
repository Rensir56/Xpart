module NPC(    
    input npc_sel,
    input br_taken,  
    input [31:0] EXinst,  
    input [63:0] alu_out,   
    input [63:0] IFpc, 
    input switch_mode,
    input [63:0] pc_csr,
    output reg [63:0] npc    
);   
  
    wire isJ;
    assign isJ = (EXinst[6:0] == 7'b1100111) || (EXinst[6:0] == 7'b1101111);

    always @(*) begin
        if ((npc_sel && br_taken) || (npc_sel && isJ)) begin
            npc = alu_out;
        end
        else if(switch_mode) begin
            npc = pc_csr;
        end
        else begin
            npc = IFpc + 4;
        end
    end
endmodule    