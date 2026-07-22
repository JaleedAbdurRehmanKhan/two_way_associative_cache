module address_separator (
    input  wire [6:0] address,      // 7-bit incoming address from TB
    output wire [2:0] tag,          // Top 3 bits
    output wire [1:0] index,        // Middle 2 bits (determines 1 of 4 sets)
    output wire [1:0] block_offset  // Bottom 2 bits
);

    // Continuous assignment to slice the address bus
    assign tag          = address[6:4];
    assign index        = address[3:2];
    assign block_offset = address[1:0];

endmodule