module mmu (
    input wire clk,
    input wire rst,

    // Virtual address input
    input wire [63:0] vaddr,
    input wire        valid_vaddr,
    output reg        ready_vaddr,

    // Physical address output
    output reg [63:0] paddr,
    output reg        valid_paddr,
    input wire        ready_paddr,

    // AXI-Lite interface for memory access
    // Write address channel
    output reg [63:0] awaddr,
    output reg        awvalid,
    input wire        awready,

    // Write data channel
    output reg [63:0] wdata,
    output reg        wvalid,
    input wire        wready,
    output reg [3:0]  wstrb,

    // Write response channel
    input wire        bvalid,
    output reg        bready,
    input wire [1:0]  bresp,

    // Read address channel
    output reg [63:0] araddr,
    output reg        arvalid,
    input wire        arready,

    // Read data channel
    input wire [63:0] rdata,
    input wire        rvalid,
    output reg        rready,
    input wire [1:0]  rresp
);

    // Page  Table Entry (PTE) structure definition
    typedef struct packed {
        logic [9:0]  reserved;
        logic [43:0] ppn; // Physical Page Number
        logic [9:0]  flags; // Permissions and other flags
    }pte_t;

    // Page table base register (simplified for demo)
    // who are you
    reg [31:0] page_table_base = 32'h1000_0000;

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

    // Initialize MMU state
    initial begin
        state = IDLE;
        ready_vaddr = 1;
        valid_paddr = 0;
        awvalid = 0;
        wvalid = 0;
        bready = 0;
        arvalid = 0;
        rready = 0;
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

    // MMU state machine
    always @(posedge clk) begin
        if (rst == 0) begin
        state = IDLE;
        ready_vaddr = 1;
        valid_paddr = 0;
        awvalid = 0;
        wvalid = 0;
        bready = 0;
        arvalid = 0;
        rready = 0;
        end else begin
            case (state)
                IDLE: begin
                    if (valid_vaddr && ready_vaddr) begin
                        // Calculate PTE , try for single level 
                        pte_address <= page_table_base + vaddr[38:30];
                        ready_vaddr <= 0;
                        araddr <= pte_address;
                        arvalid <= 1;
                        state <= TRANSLATE_L1;
                    end
                end

                TRANSLATE_L1: begin
                    if (arvalid && arready) begin
                        arvalid <= 0;
                        rready  <= 1;
                    end
                    if (rvalid && rready) begin
                        rready <= 0;
                        pte <= rdata;
                        if (!check_permmsions(pte.flags, 0)) begin
                            // Handle permission error
                            state <= IDLE;
                            ready_vaddr <= 1;
                        end else begin
                            // Calculate L2 page table entry address
                            pte_address <= (pte.ppn << 12) + vaddr[29:21];
                            araddr <= pte_address;
                            arvalid <= 1;
                            state <= TRANSLATE_L2;
                        end
                    end
                end

                TRANSLATE_L3: begin
                    if (arvalid && arready) begin
                        arvalid <= 0;
                        rready <= 1;
                    end
                    if (rvalid && rready) begin
                        rready <= 0;
                        // Read PTE from memory, demo
                        pte <= rdata;
                        // Calculate physical address
                        paddr <= {pte.ppn, vaddr[11:0]};
                        valid_paddr <= 1;
                        state <= ACCESS_MEMORY;
                    end
                end

                ACCESS_MEMORY: begin
                    if (valid_paddr && ready_paddr) begin
                        valid_paddr <= 0;
                        ready_vaddr <= 1;
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule