module cache_top (
    input  wire        clk,
    input  wire        reset,
    input  wire        tb_we,        // Write enable from the testbench
    input  wire [6:0]  address,      // 7-bit address from testbench
    input  wire [31:0] data_in,      // 32-bit data to write
    
    output wire        hit,          // Global hit flag for the testbench
    output wire [31:0] data_out      // 32-bit data read from the cache
);

    // --------------------------------------------------------
    // Internal Wires (The "breadboard" jumpers)
    // --------------------------------------------------------
    // Address separation wires
    wire [2:0] tag;
    wire [1:0] index;
    wire [1:0] block_offset;

    // Cache Way 0 outputs
    wire        way0_valid;
    wire [2:0]  way0_tag;
    wire [31:0] way0_data;
    
    // Cache Way 1 outputs
    wire        way1_valid;
    wire [2:0]  way1_tag;
    wire [31:0] way1_data;

    // Hit/Miss flags
    wire way0_hit;
    wire way1_hit;
    wire miss;

    // Controller outputs
    wire way0_we;
    wire way1_we;
    wire way_sel;

    // --------------------------------------------------------
    // Module Instantiations
    // --------------------------------------------------------
    
    // 1. Slice the 7-bit address
    address_separator addr_sep (
        .address      (address),
        .tag          (tag),
        .index        (index),
        .block_offset (block_offset)
    );

    // 2. Instantiate Way 0
    cache_way way0 (
        .clk          (clk),
        .reset        (reset),
        .write_en     (way0_we),     // Driven by the controller
        .index        (index),
        .tag_in       (tag),
        .data_in      (data_in),
        .valid_out    (way0_valid),
        .tag_out      (way0_tag),
        .data_out     (way0_data)
    );

    // 3. Instantiate Way 1
    cache_way way1 (
        .clk          (clk),
        .reset        (reset),
        .write_en     (way1_we),     // Driven by the controller
        .index        (index),
        .tag_in       (tag),
        .data_in      (data_in),
        .valid_out    (way1_valid),
        .tag_out      (way1_tag),
        .data_out     (way1_data)
    );

    // 4. Hit/Miss Comparators
    hit_miss_logic hm_logic (
        .input_tag    (tag),
        .way0_tag     (way0_tag),
        .way0_valid   (way0_valid),
        .way1_tag     (way1_tag),
        .way1_valid   (way1_valid),
        .way0_hit     (way0_hit),
        .way1_hit     (way1_hit),
        .hit          (hit),         // Outputs straight to the top level
        .miss         (miss)
    );

    // 5. The Brain / LRU / Write Controller
    cache_controller ctrl (
        .clk          (clk),
        .reset        (reset),
        .tb_we        (tb_we),
        .index        (index),
        .way0_hit     (way0_hit),
        .way1_hit     (way1_hit),
        .miss         (miss),
        .way0_valid   (way0_valid),
        .way1_valid   (way1_valid),
        .way0_we      (way0_we),
        .way1_we      (way1_we),
        .way_sel      (way_sel)
    );

    // --------------------------------------------------------
    // Final Output Multiplexer
    // --------------------------------------------------------
    // This perfectly mimics the MUX on the far right of your diagram.
    // If way_sel is 1 (Way 1 Hit), output way1_data. Otherwise, output way0_data.
    assign data_out = (way_sel == 1'b1) ? way1_data : way0_data;

endmodule