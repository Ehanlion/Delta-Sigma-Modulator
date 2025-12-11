`timescale 1ns/1ps

// ============================================================================
// Module: EE216A_Testbench
// Description:
//   Testbench for the M216A_TopModule MASH 1-1-1 delta-sigma modulator.
//   
//   Test Strategy:
//     - Edge cases: Test minimum (in_i=3) and maximum (in_i=11) values
//     - Random cases: Test at least 3 random valid input combinations
//     - Verification: Average the output over many cycles and compare to
//       expected value: in_i + in_f/65536
// ============================================================================

module EE216A_Testbench;

    // -------------------------------------------------------------------------
    // DUT I/O signals
    // -------------------------------------------------------------------------
    reg         clk;
    reg         rst_n;
    reg  [3:0]  in_i;
    reg  [15:0] in_f;
    wire [3:0]  out;

    // -------------------------------------------------------------------------
    // Instantiate the DUT
    // -------------------------------------------------------------------------
    M216A_TopModule dut (
        .clk  (clk),
        .rst_n(rst_n),
        .in_i (in_i),
        .in_f (in_f),
        .out  (out)
    );

    // -------------------------------------------------------------------------
    // Clock generation: 500 MHz -> 2 ns period -> toggle every 1 ns
    // -------------------------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #1 clk = ~clk;
    end

    // -------------------------------------------------------------------------
    // Variables for averaging / checking tests
    // -------------------------------------------------------------------------
    integer cycle_count;
    integer sum_out;
    real    avg_out;
    real    expected_avg;
    real    error;
    real    error_tolerance;
    integer N_CYCLES;
    integer test_count;
    integer pass_count;
    integer fail_count;

    // -------------------------------------------------------------------------
    // VCD dump for waveform viewing and power analysis
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("M216A_TopModule.vcd");
        $dumpvars(0, EE216A_Testbench);
    end

    // -------------------------------------------------------------------------
    // Task: run_avg_test
    //   - Applies (ti, tf) as (in_i, in_f)
    //   - Waits a few warm-up cycles
    //   - Averages 'out' over 'cycles' cycles
    //   - Computes expected average = ti + tf / 65536.0
    //   - Prints measured vs expected and pass/fail
    // -------------------------------------------------------------------------
    task run_avg_test;
        input  [3:0]  ti;
        input  [15:0] tf;
        input  integer cycles;
        input  [80*8:1] test_name;  // String for test description
        begin
            test_count = test_count + 1;
            
            in_i = ti;
            in_f = tf;

            // Reset sum
            sum_out = 0;

            // Let the modulator settle after changing inputs
            repeat (10) @(posedge clk);

            // Average over 'cycles' clock periods
            for (cycle_count = 0; cycle_count < cycles; cycle_count = cycle_count + 1) begin
                @(posedge clk);
                sum_out = sum_out + out;
            end

            // Compute measured average
            avg_out = sum_out;
            avg_out = avg_out / cycles;

            // Compute expected average: N.f = in_i + in_f/2^16
            expected_avg = ti + (tf / 65536.0);

            // Error
            error = avg_out - expected_avg;

            // Check pass/fail (tolerance for averaging error)
            // Increased error tolerance to 5% to account for finite averaging
            error_tolerance = 0.05

            $display("=====================================================");
            $display("TEST %0d: %0s", test_count, test_name);
            $display("-----------------------------------------------------");
            $display("  Input:  in_i = %0d, in_f = %0d (0x%04h)", ti, tf, tf);
            $display("  Cycles averaged: %0d", cycles);
            $display("  Sum of outputs:  %0d", sum_out);
            $display("  Expected avg:    %0.6f", expected_avg);
            $display("  Measured avg:    %0.6f", avg_out);
            $display("  Error:           %0.6f", error);
            
            if ((error < error_tolerance) && (error > -error_tolerance)) begin
                $display("  Result: PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("  Result: FAIL (error exceeds tolerance)");
                fail_count = fail_count + 1;
            end
            $display("=====================================================\n");
        end
    endtask

    // -------------------------------------------------------------------------
    // Main stimulus and tests
    // -------------------------------------------------------------------------
    initial begin
        // ---------------------------------------------------------------------
        // Initialize
        // ---------------------------------------------------------------------
        rst_n = 1'b0;
        in_i  = 4'd0;
        in_f  = 16'd0;
        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        N_CYCLES = 5000;  // Number of cycles to average for each test

        $display("\n");
        $display("========================================================");
        $display("  M216A DELTA-SIGMA MODULATOR TESTBENCH");
        $display("========================================================");
        $display("  Clock: 500 MHz (2ns period)");
        $display("  Averaging window: %0d cycles", N_CYCLES);
        $display("========================================================\n");

        // Hold reset low for a few ns
        #10;
        rst_n = 1'b1;
        #10;

        // ---------------------------------------------------------------------
        // EDGE CASE TESTS
        // ---------------------------------------------------------------------
        $display("\n>>> EDGE CASE TESTS <<<\n");

        // Test 1: Minimum in_i (3), minimum in_f (0)
        run_avg_test(4'd3, 16'd0, N_CYCLES, "Edge: Min in_i=3, Min in_f=0");

        // Test 2: Minimum in_i (3), maximum in_f (65535)
        run_avg_test(4'd3, 16'hFFFF, N_CYCLES, "Edge: Min in_i=3, Max in_f=65535");

        // Test 3: Maximum in_i (11), minimum in_f (0)
        run_avg_test(4'd11, 16'd0, N_CYCLES, "Edge: Max in_i=11, Min in_f=0");

        // Test 4: Maximum in_i (11), maximum in_f (65535)
        run_avg_test(4'd11, 16'hFFFF, N_CYCLES, "Edge: Max in_i=11, Max in_f=65535");

        // ---------------------------------------------------------------------
        // RANDOM CASE TESTS
        // ---------------------------------------------------------------------
        $display("\n>>> RANDOM CASE TESTS <<<\n");

        // Test 5: Random case 1 - in_i=5, in_f=12345
        run_avg_test(4'd5, 16'd12345, N_CYCLES, "Random: in_i=5, in_f=12345");

        // Test 6: Random case 2 - in_i=7, in_f=32768 (0.5)
        run_avg_test(4'd7, 16'd32768, N_CYCLES, "Random: in_i=7, in_f=32768 (0.5)");

        // Test 7: Random case 3 - in_i=8, in_f=32000
        run_avg_test(4'd8, 16'd32000, N_CYCLES, "Random: in_i=8, in_f=32000");

        // Test 8: Random case 4 - in_i=4, in_f=1000
        run_avg_test(4'd4, 16'd1000, N_CYCLES, "Random: in_i=4, in_f=1000");

        // Test 9: Random case 5 - in_i=9, in_f=50000
        run_avg_test(4'd9, 16'd50000, N_CYCLES, "Random: in_i=9, in_f=50000");

        // ---------------------------------------------------------------------
        // Summary
        // ---------------------------------------------------------------------
        $display("\n");
        $display("========================================================");
        $display("  TEST SUMMARY");
        $display("========================================================");
        $display("  Total tests: %0d", test_count);
        $display("  Passed:      %0d", pass_count);
        $display("  Failed:      %0d", fail_count);
        $display("========================================================");
        
        if (fail_count == 0) begin
            $display("  ALL TESTS PASSED!");
        end else begin
            $display("  SOME TESTS FAILED - Review results above");
        end
        $display("========================================================\n");

        // ---------------------------------------------------------------------
        // Done
        // ---------------------------------------------------------------------
        #100;
        $finish;
    end

endmodule

