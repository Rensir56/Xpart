module mmu (
    input wire clk,
    input wire rst,

    input wire [63:0] vaddr,
    output wire [63:0] paddr,
    output wire [63:0] addr,
    output wire       ren,
    input wire [63:0] rdata,
    input wire        mmu_stall,
    input wire        mmu_signal,
    input wire        mmu_change,
    input wire [1:0]  priv,
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
    assign pte = rdata;

    // Permissions
    logic read_enable;
    logic write_enable;

    reg   ren_reg;
    reg   paddr_valid_reg;
    reg  [63:0]  paddr_reg;

    assign ren = ren_reg & (priv != 2'b11);
    assign paddr_valid = paddr_valid_reg | (satp == 64'b0) | (priv == 2'b11);
    assign paddr = (satp == 64'b0 | priv == 2'b11) ? vaddr : paddr_reg;
    assign addr = pte_address;

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
            check_permmsions = flags[2];
            else
                check_permmsions = flags[1];
        end
    endfunction

    // Check page function
    function check_page;
        input [9:0] flags;
        begin
            check_page = !(flags[3] | flags[2] | flags[1]);
        end
    endfunction

    reg start_mmu;
    reg [63:0] last_satp;
    always @(posedge clk) begin  
        if (rst == 0) begin
            start_mmu <= 0;
            last_satp <= 64'b0;
        end else begin
             if ((mmu_change || last_satp != satp) && satp != 64'b0 && mmu_signal) begin
                start_mmu <= 1;
                paddr_valid_reg <= 0; 
             end else if (priv == 2'b11) begin
                start_mmu <= 0;
                state <= IDLE;
                ren_reg <= 0;
                // paddr_valid_reg <= 1;
                // paddr_reg <= vaddr;
            end 
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
                    if (start_mmu & (satp != 64'b0) & (priv != 2'b11)) begin
                        pte_address <= page_table_base + {52'b0 ,vaddr[38:30], 3'b0};
                        ren_reg <= 1;
                        state <= TRANSLATE_L1;
                    end
                end

                TRANSLATE_L1: begin
                    if (!mmu_stall) begin
                        if (!check_page(pte.flags)) begin
                                state <= IDLE;
                                ren_reg <= 0;
                                start_mmu <= 0;
                            if (!check_permmsions(pte.flags, 0)) begin
                                // S mode
                            end else begin
                                paddr_reg <= {8'b0, pte.ppn, 12'b0} + {34'b0, vaddr[29:0]};
                                paddr_valid_reg <= 1;
                            end
                        end else begin
                            // Calculate L2 page table entry address
                            pte_address <= {8'b0 , pte.ppn, 12'b0} + {52'b0, vaddr[29:21], 3'b0};
                            state <= TRANSLATE_L2;
                        end
                    end
                end

                TRANSLATE_L2: begin
                        if (!mmu_stall) begin
                        if (!check_page(pte.flags)) begin
                                state <= IDLE;
                                ren_reg <= 0;
                                start_mmu <= 0;
                            if (!check_permmsions(pte.flags, 0)) begin

                            end else begin
                                paddr_reg <= {8'b0, pte.ppn, 12'b0} + {43'b0, vaddr[20:0]};
                                paddr_valid_reg <= 1;
                            end
                        end else begin
                            // Calculate L3 page table entry address
                            pte_address <= {8'b0, pte.ppn, 12'b0} + {52'b0, vaddr[20:12], 3'b0};
                            state <= TRANSLATE_L3;
                        end
                    end
                end

                TRANSLATE_L3: begin
                    if (!mmu_stall) begin
                        // pte <= rdata;
                            state <= IDLE;
                            ren_reg <= 0;
                            start_mmu <= 0;
                        if (!check_permmsions(pte.flags, 0)) begin

                        end else begin
                            paddr_reg <= {8'b0, pte.ppn, 12'b0} + {52'b0, vaddr[11:0]};
                            paddr_valid_reg <= 1;
                        end
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule