module mmu (
    input wire clk,
    input wire rst,

    input wire [63:0] vaddr,
    output wire [63:0] paddr,
    output wire [63:0] addr,
    output wire       ren,
    input wire [63:0] rdata,
    input wire        mmu_stall,
    output wire       paddr_valid,

    // satp
    input wire [63:0] satp
);

    // Page  Table Entry (PTE) structure definition
    typedef struct packed {
        logic [9:0]  reserved;
        logic [43:0] ppn; // Physical Page Number
        logic [9:0]  flags; // Permissions and other flags
    }pte_t;

    // Page table base register
    reg [63:0] page_table_base = {8'b0 ,satp[43:0], 12'b0};

    // MMU state machine
    typedef enum reg [2:0] {
        IDLE,
        TRANSLATE_L1,
        TRANSLATE_L2,
        TRANSLATE_L3,
        ACCESS_MEMORY
    } mmu_state_t;

    mmu_state_t state;

    // Temproray storage for page table entries
    reg [63:0] pte_address;
    pte_t pte;

    // Permissions
    logic read_enable;
    logic write_enable;

    reg   ren_reg;
    reg   paddr_valid_reg;
    reg  [63:0]  paddr_reg;

    assign ren = ren_reg;
    assign paddr_valid = paddr_valid_reg | (satp == 64'b0);
    assign paddr = (satp == 64'b0) ? vaddr : paddr_reg;

    // Initialize MMU state
    initial begin
        state = IDLE;
        paddr_valid_reg = 1'b0;
        ren_reg = 1'b0;
    end

    // Permissions check function
    function check_permmsions;
        input [9:0] flags;
        input       is_write;
        begin
            if (is_write)
            check_permmsions = flags[1];
            else
                check_permmsions = flags[0];
        end
    endfunction

    reg start_mmu;
    reg [63:0] last_vaddr;
    reg [63:0] last_satp;
    always @(posedge clk) begin  //TODO
        if (rst == 0) begin
            start_mmu <= 0;
            last_vaddr <= 64'b0;
            last_satp <= 64'b0;
        end else begin
            if ((last_vaddr != vaddr && satp != 64'b0) || last_satp != satp) begin
                start_mmu <= 1;
            end
            last_vaddr <= vaddr;
            last_satp <= satp;
        end
    end


    // MMU state machine
    always @(posedge clk) begin
        if (rst == 0) begin
        state <= IDLE;
        paddr_valid_reg <= 0;
        ren_reg <= 0;
        // end else if (flush)begin  TODO
        //     state <= IDLE;
        //     start_mmu <= 0;
        //     ren_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start_mmu | (satp != 64'b0)) begin
                        paddr_valid_reg <= 0;
                        // Calculate PTE , try for single level 
                        pte_address <= page_table_base + {55'b0 ,vaddr[38:30]};
                        ren_reg <= 1;
                        state <= TRANSLATE_L1;
                    end
                end

                TRANSLATE_L1: begin
                    if (!mmu_stall) begin
                        pte <= rdata;
                        if (!check_permmsions(pte.flags, 0)) begin
                            // Handle permission error
                            state <= IDLE;
                            ren_reg <= 0;
                            start_mmu <= 0;
                        end else begin
                            // Calculate L2 page table entry address
                            pte_address <= {8'b0 , pte.ppn, 12'b0} + {55'b0, vaddr[29:21]};
                            state <= TRANSLATE_L2;
                        end
                    end
                end

                TRANSLATE_L2: begin
                        if (!mmu_stall) begin
                        pte <= rdata;
                        if (!check_permmsions(pte.flags, 0)) begin
                            // Handle permission error
                            state <= IDLE;
                            ren_reg <= 0;
                            start_mmu <= 0;
                        end else begin
                            // Calculate L3 page table entry address
                            pte_address <= {8'b0, pte.ppn, 12'b0} + {55'b0, vaddr[20:12]};
                            state <= TRANSLATE_L3;
                        end
                    end
                end

                TRANSLATE_L3: begin
                    if (!mmu_stall) begin
                        pte <= rdata;
                        if (!check_permmsions(pte.flags, 0)) begin
                            state <= IDLE;
                            ren_reg <= 0;
                            start_mmu <= 0;
                        end else begin
                            paddr_reg <= {8'b0, pte.ppn, 12'b0} + {52'b0, vaddr[11:0]};
                            paddr_valid_reg <= 1;
                            state <= IDLE;//ACCESS_MEMORY;
                            start_mmu <= 0;
                        end
                    end
                end

                // ACCESS_MEMORY: begin
                //     if (valid_paddr && ready_paddr) begin
                //         valid_paddr <= 0;
                //         ready_vaddr <= 1;
                //         state <= IDLE;
                //     end
                // end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule