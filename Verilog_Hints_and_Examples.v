// ============================================================================
// VERILOG HINTS AND EXAMPLES FOR M216A PROJECT
// ============================================================================
// This file provides code examples for the key Verilog concepts you'll need
// to successfully complete the MASH 1-1-1 Delta-Sigma Modulator project.
//
// Topics Covered:
//   1. Module Declaration and Ports
//   2. Parameters
//   3. Wire vs Reg
//   4. Always Blocks (Sequential Logic)
//   5. Combinational Logic
//   6. Signed vs Unsigned Arithmetic
//   7. Module Instantiation and Interconnection
//   8. Testbench Basics
// ============================================================================

`timescale 1ns/1ps

// ============================================================================
// SECTION 1: MODULE DECLARATION AND PORTS
// ============================================================================
// A module is like a circuit block with inputs and outputs.
// Syntax: module <name> ( <port_list> );

module example_basic_module (
    input wire        clk,      // Single-bit input
    input wire        rst_n,    // Active-low reset (common convention)
    input wire [7:0]  data_in,  // 8-bit input bus
    output reg [7:0]  data_out, // 8-bit output (registered)
    output wire       flag      // Single-bit output (combinational)
);

    // Module body goes here
    // (We'll fill this in with examples below)

endmodule


// ============================================================================
// SECTION 2: PARAMETERS
// ============================================================================
// Parameters allow you to create reusable, configurable modules.
// They are like constants that can be overridden during instantiation.

module example_parameterized_module #(
    parameter WIDTH = 16,        // Default width is 16 bits
    parameter DEPTH = 8          // Default depth
)(
    input wire [WIDTH-1:0] in_data,
    output reg [WIDTH-1:0] out_data
);

    // You can use WIDTH throughout the module
    reg [WIDTH-1:0] internal_register;

    // Example: A simple pass-through
    always @(*) begin
        out_data = in_data;
    end

endmodule


// ============================================================================
// SECTION 3: WIRE vs REG
// ============================================================================
// - WIRE: Used for combinational signals (continuous assignment)
// - REG: Used for signals assigned in always blocks (can be sequential or comb)
//
// IMPORTANT: "reg" doesn't always mean a physical register/flip-flop!
//            It just means "assigned in an always block"

module example_wire_vs_reg (
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [7:0] sum_wire,   // Combinational output
    output reg [7:0]  sum_reg     // Can be sequential or combinational
);

    // WIRE: Continuous assignment (always active, no clock)
    assign sum_wire = a + b;

    // REG: Assigned in always block (this example is combinational)
    always @(*) begin
        sum_reg = a + b;
    end

    // Note: Both achieve the same result here, but "reg" is needed
    // when you want sequential (clocked) logic.

endmodule


// ============================================================================
// SECTION 4: ALWAYS BLOCKS - SEQUENTIAL LOGIC (FLIP-FLOPS)
// ============================================================================
// Sequential logic updates on clock edges and typically includes reset logic.
// Pattern: always @(posedge clk or negedge rst_n)
//
// This creates actual flip-flops in hardware.

module example_sequential_logic (
    input wire        clk,
    input wire        rst_n,     // Active-low asynchronous reset
    input wire [15:0] data_in,
    output reg [15:0] data_out,
    output reg        carry_out
);

    // Internal state (accumulator)
    reg [15:0] accumulator;

    // Sequential always block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // RESET: Initialize all registers
            accumulator <= 16'd0;
            data_out    <= 16'd0;
            carry_out   <= 1'b0;
        end else begin
            // NORMAL OPERATION: Update on clock edge
            {carry_out, accumulator} <= accumulator + data_in;  // 17-bit addition
            data_out <= accumulator;
        end
    end

    // Key Points:
    // - Use "posedge clk" for rising edge
    // - Use "negedge rst_n" for async active-low reset
    // - Use "<=" (non-blocking assignment) in sequential blocks
    // - All signals assigned here become flip-flops

endmodule


// ============================================================================
// SECTION 5: ALWAYS BLOCKS - COMBINATIONAL LOGIC
// ============================================================================
// Combinational logic has no clock, just responds to input changes.
// Pattern: always @(*)  -- the (*) means "sensitive to all inputs"

module example_combinational_logic (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire       sel,
    output reg [3:0] result
);

    // Combinational always block
    always @(*) begin
        if (sel) begin
            result = a + b;
        end else begin
            result = a - b;
        end
    end

    // Key Points:
    // - Use @(*) for combinational logic
    // - Use "=" (blocking assignment) in combinational blocks
    // - No clock, no reset needed

endmodule


// ============================================================================
// SECTION 6: SIGNED vs UNSIGNED ARITHMETIC
// ============================================================================
// By default, Verilog treats all values as UNSIGNED.
// Use "signed" keyword for signed arithmetic.

module example_signed_arithmetic (
    input wire signed [3:0] signed_a,    // Signed 4-bit input
    input wire [3:0]        unsigned_b,  // Unsigned 4-bit input
    output reg signed [4:0] result       // Signed 5-bit output
);

    // Mixing signed and unsigned requires careful handling
    always @(*) begin
        // Convert unsigned to signed before arithmetic
        result = signed_a + $signed({1'b0, unsigned_b});
        
        // Alternative: explicitly extend sign
        // result = signed_a + {{1{unsigned_b[3]}}, unsigned_b};
    end

    // Key Points:
    // - Use "signed" keyword in port declarations
    // - Use $signed() to cast unsigned to signed
    // - Use $unsigned() to cast signed to unsigned
    // - Be careful with bit widths to avoid overflow

endmodule


// ============================================================================
// SECTION 7: MODULE INSTANTIATION AND INTERCONNECTION
// ============================================================================
// This is CRITICAL for your project! You'll instantiate multiple mash_stage
// modules and connect them together.

module example_top_module (
    input wire        clk,
    input wire        rst_n,
    input wire [15:0] input_value,
    output wire [3:0] final_output
);

    // -------------------------------------------------------------------------
    // Step 1: Declare wires to connect modules
    // -------------------------------------------------------------------------
    wire [15:0] error1, error2, error3;  // Error outputs from stages
    wire        carry1, carry2, carry3;  // Carry outputs from stages
    wire signed [3:0] fractional_correction;

    // -------------------------------------------------------------------------
    // Step 2: Instantiate sub-modules
    // -------------------------------------------------------------------------
    
    // Instance 1: First accumulator stage
    // Syntax: <module_name> #(<params>) <instance_name> (<port_connections>);
    example_accumulator #(
        .WIDTH(16)                    // Override parameter
    ) stage1 (
        .clk(clk),                    // Connect clock
        .rst_n(rst_n),                // Connect reset
        .in_val(input_value),         // Connect input
        .e_out(error1),               // Connect to wire
        .c_out(carry1)                // Connect to wire
    );

    // Instance 2: Second accumulator stage (cascaded)
    example_accumulator #(
        .WIDTH(16)
    ) stage2 (
        .clk(clk),
        .rst_n(rst_n),
        .in_val(error1),              // Input is error from stage1
        .e_out(error2),
        .c_out(carry2)
    );

    // Instance 3: Third accumulator stage
    example_accumulator #(
        .WIDTH(16)
    ) stage3 (
        .clk(clk),
        .rst_n(rst_n),
        .in_val(error2),              // Input is error from stage2
        .e_out(error3),
        .c_out(carry3)
    );

    // Instance 4: Noise shaper combines the carries
    example_noise_shaper shaper (
        .clk(clk),
        .rst_n(rst_n),
        .c1(carry1),
        .c2(carry2),
        .c3(carry3),
        .out_f(fractional_correction)
    );

    // -------------------------------------------------------------------------
    // Step 3: Final output logic
    // -------------------------------------------------------------------------
    reg [3:0] output_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            output_reg <= 4'd0;
        end else begin
            // Add integer part (not shown) with fractional correction
            output_reg <= fractional_correction[3:0];
        end
    end

    assign final_output = output_reg;

    // Key Points:
    // - Declare wires for all inter-module connections
    // - Use #(parameter) syntax to override parameters
    // - Use .port_name(signal_name) for clarity (named association)
    // - You can also use positional: module_name inst (.port1(sig1), .port2(sig2));

endmodule


// ============================================================================
// HELPER MODULES FOR SECTION 7 EXAMPLE
// ============================================================================

module example_accumulator #(
    parameter WIDTH = 16
)(
    input wire                clk,
    input wire                rst_n,
    input wire [WIDTH-1:0]    in_val,
    output reg [WIDTH-1:0]    e_out,
    output reg                c_out
);
    reg [WIDTH-1:0] acc;
    wire [WIDTH:0] sum;
    
    assign sum = {1'b0, acc} + {1'b0, in_val};
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc <= {WIDTH{1'b0}};
            e_out <= {WIDTH{1'b0}};
            c_out <= 1'b0;
        end else begin
            acc <= sum[WIDTH-1:0];
            e_out <= sum[WIDTH-1:0];
            c_out <= sum[WIDTH];
        end
    end
endmodule

module example_noise_shaper (
    input wire        clk,
    input wire        rst_n,
    input wire        c1,
    input wire        c2,
    input wire        c3,
    output reg signed [3:0] out_f
);
    reg c2_d1, c3_d1, c3_d2;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c2_d1 <= 1'b0;
            c3_d1 <= 1'b0;
            c3_d2 <= 1'b0;
            out_f <= 4'sd0;
        end else begin
            c2_d1 <= c2;
            c3_d2 <= c3_d1;
            c3_d1 <= c3;
            
            // Simplified noise shaping equation
            out_f <= $signed({3'b000, c1}) + 
                     $signed({3'b000, c2_d1}) - $signed({3'b000, c2});
        end
    end
endmodule


// ============================================================================
// SECTION 8: TESTBENCH BASICS
// ============================================================================
// Testbenches have no ports and use "initial" blocks to generate stimulus.

module example_testbench;

    // -------------------------------------------------------------------------
    // Declare signals to connect to DUT (Device Under Test)
    // -------------------------------------------------------------------------
    reg        clk;
    reg        rst_n;
    reg [15:0] test_input;
    wire [3:0] test_output;

    // -------------------------------------------------------------------------
    // Instantiate the DUT
    // -------------------------------------------------------------------------
    example_top_module dut (
        .clk(clk),
        .rst_n(rst_n),
        .input_value(test_input),
        .final_output(test_output)
    );

    // -------------------------------------------------------------------------
    // Clock generation
    // -------------------------------------------------------------------------
    // For 500 MHz clock: period = 2ns, toggle every 1ns
    initial begin
        clk = 1'b0;
        forever #1 clk = ~clk;  // Toggle every 1ns
    end

    // -------------------------------------------------------------------------
    // Stimulus generation
    // -------------------------------------------------------------------------
    initial begin
        // Initialize signals
        rst_n = 1'b0;
        test_input = 16'd0;

        // Hold reset for a few cycles
        #10;
        rst_n = 1'b1;

        // Apply test vectors
        #10;
        test_input = 16'd1000;

        #100;
        test_input = 16'd5000;

        #100;
        test_input = 16'd32768;

        // Run for some time
        #1000;

        // End simulation
        $display("Simulation complete!");
        $finish;
    end

    // -------------------------------------------------------------------------
    // Optional: Waveform dumping for viewing in GTKWave or power analysis
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("example_test.vcd");
        $dumpvars(0, example_testbench);
    end

    // -------------------------------------------------------------------------
    // Optional: Monitor signals during simulation
    // -------------------------------------------------------------------------
    initial begin
        $monitor("Time=%0t rst_n=%b input=%d output=%d", 
                 $time, rst_n, test_input, test_output);
    end

    // Key Points:
    // - Use "reg" for inputs you drive, "wire" for outputs you observe
    // - Use "initial" blocks for stimulus (not synthesizable)
    // - Use $dumpfile/$dumpvars for VCD generation (needed for power analysis)
    // - Use $display for printing messages
    // - Use $finish to end simulation
    // - Use #<time> for delays (e.g., #10 means wait 10 time units)

endmodule


// ============================================================================
// ADDITIONAL TIPS FOR YOUR PROJECT
// ============================================================================
//
// 1. CONCATENATION: Use {} to combine bits
//    Example: {carry, sum} = a + b;  // 17-bit result split into 1-bit + 16-bit
//
// 2. REPLICATION: Use {N{bit}} to repeat a bit N times
//    Example: {16{1'b0}} creates 16 zeros
//
// 3. BIT SELECTION:
//    - Single bit: signal[3]
//    - Range: signal[7:4]
//    - Variable index: signal[index]
//
// 4. ARITHMETIC SHIFT: Use <<< and >>> for signed shifts
//    Example: value <<< 1  // Multiply by 2 (preserves sign)
//
// 5. SYSTEM TASKS (for testbench):
//    - $display("text %d", value);  // Print to console
//    - $monitor("...");              // Print on signal change
//    - $time                         // Current simulation time
//    - $random                       // Random number
//    - $finish                       // End simulation
//    - $stop                         // Pause simulation
//
// 6. COMMON MISTAKES:
//    - Using "=" in sequential blocks (use "<=")
//    - Using "<=" in combinational blocks (use "=")
//    - Forgetting to list all inputs in sensitivity list (use @(*))
//    - Mixing signed/unsigned without casting
//    - Not initializing registers in reset
//
// 7. FOR YOUR MASH PROJECT:
//    - Make mash_stage parameterized (WIDTH parameter)
//    - Use non-blocking assignments (<=) in all clocked always blocks
//    - Carefully handle signed arithmetic in noise_shaper
//    - Remember: c1, c2, c3 are unsigned (0 or 1), but out_f is signed
//    - Test with multiple input values in testbench
//    - Run for many cycles (5000+) to get accurate average
//
// ============================================================================

