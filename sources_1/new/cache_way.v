module cache_way (
    input  wire        clk,
    input  wire        reset,      // Active high reset to clear valid bits
    input  wire        write_en,   // Enables writing to this specific way
    input  wire [1:0]  index,      // 2-bit index selects the row (0 to 3)
    input  wire [2:0]  tag_in,     // 3-bit tag to store
    input  wire [31:0] data_in,    // 32-bit data to store
    
    output wire        valid_out,  // Valid bit for the selected index
    output wire [2:0]  tag_out,    // Tag stored at the selected index
    output wire [31:0] data_out    // Data stored at the selected index
);

    // The physical memory arrays (4 sets deep)
    reg        valid_array [0:3];
    reg [2:0]  tag_array   [0:3];
    reg [31:0] data_array  [0:3];
    
    integer i;

    // Synchronous Write and Reset Logic
    always @(posedge clk) begin
        if (reset) begin
            // As you planned, set all valid bits to 0 on reset so initial reads miss
            for (i = 0; i < 4; i = i + 1) begin
                valid_array[i] <= 1'b0; 
            end
        end else if (write_en) begin
            // Write the new tag and data, and flip the valid bit to 1
            valid_array[index] <= 1'b1;       
            tag_array[index]   <= tag_in;     
            data_array[index]  <= data_in;    
        end
    end

    // Asynchronous/Continuous Read Logic
    // These outputs continuously feed into your hit/miss comparators
    assign valid_out = valid_array[index];
    assign tag_out   = tag_array[index];
    assign data_out  = data_array[index];

endmodule