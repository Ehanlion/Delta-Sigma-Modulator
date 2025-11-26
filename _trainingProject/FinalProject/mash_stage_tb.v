`timescale 1ns/1ps

module mash_stage_tb;

    // Testbench signals
    reg         clk;
    reg         rst_n;
    reg  [15:0] in_val;
    wire [15:0] e_out;
    wire        c_out;

    // Instantiate DUT
    mash_stage dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_val(in_val),
        .e_out(e_out),
        .c_out(c_out)
    );

    // 500 MHz clock = 2 ns period = toggle every 1 ns
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Display header
        $display("Time    in_val      e_out      c_out");

        // Reset
        rst_n = 0;
        in_val = 16'd0;
        #5;              // wait 5 ns
        rst_n = 1;

        // Test 1: Add small number repeatedly
        // Expect: e_out increments by 5 each cycle
        $display("\nTEST 1: adding 5 repeatedly");
        in_val = 16'd5;

        repeat (10) begin
            @(posedge clk);
            $display("%0t    %0d      %0d      %0b", $time, in_val, e_out, c_out);
        end

        // Test 2: Force carry-out
        // Add a big value to overflow the 16-bit accumulator
        $display("\nTEST 2: force carry-out");
        rst_n = 0; @(posedge clk); rst_n = 1;   // reset accumulator
        in_val = 16'hF000; // large value

        repeat (5) begin
            @(posedge clk);
            $display("%0t    %h      %h      %0b", $time, in_val, e_out, c_out);
        end

        // End simulation
        $display("\nSimulation complete.");
        #10;
        $stop;
    end

endmodule
