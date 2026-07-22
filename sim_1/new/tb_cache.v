`timescale 1ns / 1ps

module tb_cache;

    // Inputs to the Cache
    reg        clk;
    reg        reset;
    reg        tb_we;
    reg [6:0]  address;
    reg [31:0] data_in;

    // Outputs from the Cache
    wire        hit;
    wire [31:0] data_out;

    // Instantiate the Top-Level Cache
    cache_top uut (
        .clk      (clk),
        .reset    (reset),
        .tb_we    (tb_we),
        .address  (address),
        .data_in  (data_in),
        .hit      (hit),
        .data_out (data_out)
    );

    // Generate a 10ns Clock (Toggles every 5ns)
    always #5 clk = ~clk;

    initial begin
        // --------------------------------------------------------
        // System Initialization & Reset
        // --------------------------------------------------------
        clk     = 0;
        tb_we   = 0;
        address = 7'b0000000;
        data_in = 32'h00000000;
        
        // Apply Reset
        reset = 1;
        #15; 
        reset = 0;
        #10;
        $display("--- System Reset Complete. All Valid bits are 0 ---");

        // --------------------------------------------------------
        // Test 1: Initial Read (Should Miss)
        // Address: Tag = 001, Index = 00, Offset = 00 -> 7'b001_00_00
        // --------------------------------------------------------
        address = 7'b001_00_00;
        tb_we   = 0;
        #10;
        $display("Test 1 (Initial Read) | Address: %b | Hit: %b (Expected: 0)", address, hit);

        // --------------------------------------------------------
        // Test 2: Write to Way 0
        // --------------------------------------------------------
        address = 7'b001_00_00;
        data_in = 32'hAAAA_1111;
        tb_we   = 1;
        #10;  // Wait for clock edge to write
        tb_we   = 0; // Turn off write enable
        #10;
        $display("Test 2 (Write)        | Wrote %h to Tag 001, Index 00", data_in);

        // --------------------------------------------------------
        // Test 3: Read Hit on Way 0
        // --------------------------------------------------------
        address = 7'b001_00_00;
        tb_we   = 0;
        #10;
        $display("Test 3 (Read Way 0)   | Hit: %b (Expected: 1) | Data: %h", hit, data_out);
        // Note: Because we just read Way 0, the LRU bit for Index 00 now points to Way 1.

        // --------------------------------------------------------
        // Test 4: Write to Way 1 (Same Index, Different Tag)
        // Address: Tag = 010, Index = 00, Offset = 00 -> 7'b010_00_00
        // --------------------------------------------------------
        address = 7'b010_00_00;
        data_in = 32'hBBBB_2222;
        tb_we   = 1;
        #10;
        tb_we   = 0;
        #10;
        $display("Test 4 (Write)        | Wrote %h to Tag 010, Index 00 (Way 1)", data_in);

        // --------------------------------------------------------
        // Test 5: Read Hit on Way 1
        // --------------------------------------------------------
        address = 7'b010_00_00;
        tb_we   = 0;
        #10;
        $display("Test 5 (Read Way 1)   | Hit: %b (Expected: 1) | Data: %h", hit, data_out);
        // Note: Because we just read Way 1, the LRU bit for Index 00 now flips back to point to Way 0.

        // --------------------------------------------------------
        // Test 6: Force LRU Eviction (Write a 3rd Tag to Index 00)
        // Address: Tag = 011, Index = 00, Offset = 00 -> 7'b011_00_00
        // --------------------------------------------------------
        // Both ways are full. LRU bit says Way 0 is oldest. This should overwrite Way 0.
        address = 7'b011_00_00;
        data_in = 32'hCCCC_3333;
        tb_we   = 1;
        #10;
        tb_we   = 0;
        #10;
        $display("Test 6 (Eviction)     | Wrote %h to Tag 011, Index 00. Overwriting Way 0.", data_in);

        // --------------------------------------------------------
        // Test 7: Verify Eviction
        // Read the original Tag 001. It should now be a MISS.
        // --------------------------------------------------------
        address = 7'b001_00_00;
        tb_we   = 0;
        #10;
        $display("Test 7a(Verify Evict) | Read Old Tag 001 | Hit: %b (Expected: 0 - MISS!)", hit);

        // Read the new Tag 011. It should be a HIT.
        address = 7'b011_00_00;
        tb_we   = 0;
        #10;
        $display("Test 7b(Verify Evict) | Read New Tag 011 | Hit: %b (Expected: 1) | Data: %h", hit, data_out);

        // --------------------------------------------------------
        // End Simulation
        // --------------------------------------------------------
        #20;
        $display("--- Simulation Complete ---");
        $finish;
    end

endmodule