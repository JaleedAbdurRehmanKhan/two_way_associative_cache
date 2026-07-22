module hit_miss_logic (
    input  wire [2:0] input_tag,    // 3-bit tag from the incoming address
    input  wire [2:0] way0_tag,     // Tag continuously read from Way 0
    input  wire       way0_valid,   // Valid bit continuously read from Way 0
    input  wire [2:0] way1_tag,     // Tag continuously read from Way 1
    input  wire       way1_valid,   // Valid bit continuously read from Way 1

    output wire       way0_hit,     // High if Way 0 is a match and valid
    output wire       way1_hit,     // High if Way 1 is a match and valid
    output wire       hit,          // High if either way is a hit
    output wire       miss          // High if neither way is a hit
);

    // Way 0 Logic: Comparator AND Valid bit
    assign way0_hit = (input_tag == way0_tag) & way0_valid;

    // Way 1 Logic: Comparator AND Valid bit
    assign way1_hit = (input_tag == way1_tag) & way1_valid;

    // Overall Hit/Miss Logic: OR gate and Inverter
    assign hit  = way0_hit | way1_hit;
    assign miss = ~hit;

endmodule