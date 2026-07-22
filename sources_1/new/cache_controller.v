module cache_controller (
    input  wire       clk,
    input  wire       reset,
    input  wire       tb_we,        // Testbench Write Enable
    input  wire [1:0] index,        // Determines which of the 4 sets to check/update
    
    // Status flags from hit_miss_logic and cache_way modules
    input  wire       way0_hit,
    input  wire       way1_hit,
    input  wire       miss,
    input  wire       way0_valid,
    input  wire       way1_valid,

    // Outputs to control the cache ways and output multiplexer
    output reg        way0_we,
    output reg        way1_we,
    output wire       way_sel       // Controls the final data output MUX
);

    // LRU Array: 4 sets deep, 1 bit wide.
    // 0 = Way 0 is oldest (evict Way 0)
    // 1 = Way 1 is oldest (evict Way 1)
    reg lru_array [0:3];
    integer i;

    // --------------------------------------------------------
    // Block 1: Write Enable Decision Matrix (Combinational)
    // --------------------------------------------------------
    always @(*) begin
        // Default: Do not write anything unless conditions are met
        way0_we = 1'b0;
        way1_we = 1'b0;
        
        if (tb_we) begin
            if (way0_hit) begin
                way0_we = 1'b1;                 // Scenario A: Update Way 0
            end else if (way1_hit) begin
                way1_we = 1'b1;                 // Scenario B: Update Way 1
            end else if (miss) begin
                if (!way0_valid) begin
                    way0_we = 1'b1;             // Scenario C: Fill empty Way 0
                end else if (!way1_valid) begin
                    way1_we = 1'b1;             // Scenario D: Fill empty Way 1
                end else begin
                    // Scenario E: Both full. Use LRU bit to evict.
                    if (lru_array[index] == 1'b0) begin
                        way0_we = 1'b1;         // LRU says Way 0 is oldest
                    end else begin
                        way1_we = 1'b1;         // LRU says Way 1 is oldest
                    end
                end
            end
        end
    end

    // --------------------------------------------------------
    // Block 2: LRU Array Updates (Synchronous)
    // --------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 4; i = i + 1) begin
                lru_array[i] <= 1'b0;           // Default to evicting Way 0 on reset
            end
        end else begin
            // Update LRU if the row is touched (either by a read Hit or a Write)
            if (way0_hit || way0_we) begin
                lru_array[index] <= 1'b1;       // Touched Way 0 -> Way 1 is now oldest
            end 
            else if (way1_hit || way1_we) begin
                lru_array[index] <= 1'b0;       // Touched Way 1 -> Way 0 is now oldest
            end
        end
    end

    // --------------------------------------------------------
    // Block 3: The Data Multiplexer Selector
    // --------------------------------------------------------
    // If it's a hit on Way 1, select 1. Otherwise, default to 0.
    // This hooks up directly to the MUX at the far right of your diagram.
    assign way_sel = way1_hit; 

endmodule