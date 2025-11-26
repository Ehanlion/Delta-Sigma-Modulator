`timescale 1ns/1ps

// ============================================================================
// Module: noise_shaper_tb
// Description:
//   Testbench for the noise_shaper module
//
//   Tests:
//     1. All zeros input
//     2. DC input on c1 only
//     3. Pulse on c2 (first-order differentiator effect)
//     4. Pulse on c3 (second-order differentiator effect)
//     5. Random carry patterns
//     6. Range verification (out_f should stay in [-3, +4])
// ============================================================================

module noise_shaper_tb;

    // -------------------------------------------------------------------------
    // Testbench signals
    // -------------------------------------------------------------------------
    reg         clk;
    reg         rst_n;
    reg         c1;
    reg         c2;
    reg         c3;
    wire signed [3:0] out_f;

    // -------------------------------------------------------------------------
    // Instantiate DUT
    // -------------------------------------------------------------------------
    noise_shaper dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .c1     (c1),
        .c2     (c2),
        .c3     (c3),
        .out_f  (out_f)
    );

    // -------------------------------------------------------------------------
    // Clock generation: 500 MHz (2 ns period, toggle every 1 ns)
    // -------------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    // -------------------------------------------------------------------------
    // Test variables
    // -------------------------------------------------------------------------
    integer test_num;
    integer pass_count;
    integer fail_count;
    integer i;
    integer violations;

    // -------------------------------------------------------------------------
    // Main test stimulus
    // -------------------------------------------------------------------------
    initial begin
        test_num = 0;
        pass_count = 0;
        fail_count = 0;

        $display("\n========================================================");
        $display("  NOISE SHAPER TESTBENCH");
        $display("========================================================");
        $display("  Testing noise shaping transfer function:");
        $display("  out_f(z) = c1 + (z^-1 - 1)*c2 + (z^-1 - 1)^2*c3");
        $display("========================================================\n");

        // Initialize
        rst_n = 0;
        c1 = 0;
        c2 = 0;
        c3 = 0;
        #10;
        rst_n = 1;
        @(posedge clk);

        // ---------------------------------------------------------------------
        // TEST 1: All zeros
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: All Zeros Input", test_num);
        $display("-----------------------------------------------------");
        $display("  Expect: out_f = 0 for all cycles");
        $display("  Time    c1 c2 c3   out_f");
        
        c1 = 0; c2 = 0; c3 = 0;
        repeat (8) begin
            @(posedge clk);
            $display("  %5t   %0b  %0b  %0b      %2d", $time, c1, c2, c3, out_f);
        end
        
        if (out_f == 4'sd0) begin
            $display("  PASS: Output is zero");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Output is not zero (%0d)", out_f);
            fail_count = fail_count + 1;
        end
        $display("");

        // ---------------------------------------------------------------------
        // TEST 2: DC on c1 (c1=1, c2=c3=0)
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: DC Input on c1", test_num);
        $display("-----------------------------------------------------");
        $display("  Expect: out_f should settle to +1");
        $display("  Time    c1 c2 c3   out_f");
        
        c1 = 1; c2 = 0; c3 = 0;
        repeat (10) begin
            @(posedge clk);
            $display("  %5t   %0b  %0b  %0b      %2d", $time, c1, c2, c3, out_f);
        end
        
        if (out_f == 4'sd1) begin
            $display("  PASS: Output settled to +1");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Output did not settle to +1 (got %0d)", out_f);
            fail_count = fail_count + 1;
        end
        $display("");

        // ---------------------------------------------------------------------
        // TEST 3: Pulse on c2
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: Pulse on c2", test_num);
        $display("-----------------------------------------------------");
        $display("  Testing (z^-1 - 1)*c2 term");
        $display("  Time    c1 c2 c3   out_f");
        
        c1 = 0; c2 = 0; c3 = 0;
        repeat (3) begin
            @(posedge clk);
            $display("  %5t   %0b  %0b  %0b      %2d", $time, c1, c2, c3, out_f);
        end

        // Single pulse on c2
        c2 = 1;
        @(posedge clk);
        $display("  %5t   %0b  %0b  %0b      %2d  <- c2 pulse", $time, c1, c2, c3, out_f);

        c2 = 0;
        repeat (5) begin
            @(posedge clk);
            $display("  %5t   %0b  %0b  %0b      %2d", $time, c1, c2, c3, out_f);
        end
        
        // After the transient, output should settle back to zero
        if (out_f == 4'sd0) begin
            $display("  PASS: Output settled back to zero after transient");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Output did not settle to zero (got %0d)", out_f);
            fail_count = fail_count + 1;
        end
        $display("");

        // ---------------------------------------------------------------------
        // TEST 4: Pulse on c3
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: Pulse on c3", test_num);
        $display("-----------------------------------------------------");
        $display("  Testing (z^-1 - 1)^2*c3 term");
        $display("  Time    c1 c2 c3   out_f");
        
        c1 = 0; c2 = 0; c3 = 0;
        repeat (3) begin
            @(posedge clk);
            $display("  %5t   %0b  %0b  %0b      %2d", $time, c1, c2, c3, out_f);
        end

        c3 = 1;
        @(posedge clk);
        $display("  %5t   %0b  %0b  %0b      %2d  <- c3 pulse", $time, c1, c2, c3, out_f);

        c3 = 0;
        repeat (6) begin
            @(posedge clk);
            $display("  %5t   %0b  %0b  %0b      %2d", $time, c1, c2, c3, out_f);
        end
        
        // After the transient, output should settle back to zero
        if (out_f == 4'sd0) begin
            $display("  PASS: Output settled back to zero after transient");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Output did not settle to zero (got %0d)", out_f);
            fail_count = fail_count + 1;
        end
        $display("");

        // ---------------------------------------------------------------------
        // TEST 5: All ones
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: All Ones Input", test_num);
        $display("-----------------------------------------------------");
        $display("  c1=c2=c3=1, should settle to c1 only (others cancel)");
        $display("  Time    c1 c2 c3   out_f");
        
        c1 = 1; c2 = 1; c3 = 1;
        repeat (10) begin
            @(posedge clk);
            $display("  %5t   %0b  %0b  %0b      %2d", $time, c1, c2, c3, out_f);
        end
        
        // Differentiator terms should cancel, leaving only c1
        if (out_f == 4'sd1) begin
            $display("  PASS: Output settled to c1 value (+1)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Output should be +1 (got %0d)", out_f);
            fail_count = fail_count + 1;
        end
        $display("");

        // ---------------------------------------------------------------------
        // TEST 6: Random carry patterns with range check
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: Random Carry Patterns (Range Check)", test_num);
        $display("-----------------------------------------------------");
        $display("  Testing 1000 random carry combinations");
        $display("  Verifying out_f stays within [-3, +4]");
        
        violations = 0;
        
        for (i = 0; i < 1000; i = i + 1) begin
            c1 = $random & 1;
            c2 = $random & 1;
            c3 = $random & 1;
            @(posedge clk);
            
            if ((out_f > 4) || (out_f < -3)) begin
                violations = violations + 1;
                if (violations <= 5) begin  // Only print first 5 violations
                    $display("  VIOLATION at %0t: c1=%b c2=%b c3=%b out_f=%0d", 
                             $time, c1, c2, c3, out_f);
                end
            end
        end
        
        $display("  Random tests completed: %0d cycles", i);
        $display("  Range violations: %0d", violations);
        
        if (violations == 0) begin
            $display("  PASS: All outputs within [-3, +4] range");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: %0d outputs exceeded range", violations);
            fail_count = fail_count + 1;
        end
        $display("");

        // ---------------------------------------------------------------------
        // TEST 7: Alternating pattern
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: Alternating Pattern", test_num);
        $display("-----------------------------------------------------");
        $display("  Alternating c1 between 0 and 1");
        $display("  Time    c1 c2 c3   out_f");
        
        // Reset to clear any state from previous tests
        rst_n = 0; c1 = 0; c2 = 0; c3 = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        violations = 0;
        
        for (i = 0; i < 10; i = i + 1) begin
            c1 = i % 2;
            @(posedge clk);
            $display("  %5t   %0b  %0b  %0b      %2d", $time, c1, c2, c3, out_f);
            
            // After the first few cycles (to allow settling), check the pattern
            if (i >= 2) begin
                // out_f should match the previous c1 value (1-cycle delay)
                if (out_f != ((i-1) % 2)) begin
                    violations = violations + 1;
                end
            end
        end
        
        // Output should alternate between 0 and 1 (with 1-cycle delay)
        if (violations == 0) begin
            $display("  PASS: Output follows c1 input (with proper delay)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Output pattern incorrect (%0d violations)", violations);
            fail_count = fail_count + 1;
        end
        $display("");

        // ---------------------------------------------------------------------
        // Summary
        // ---------------------------------------------------------------------
        $display("\n========================================================");
        $display("  TEST SUMMARY");
        $display("========================================================");
        $display("  Total tests: %0d", test_num);
        $display("  Passed:      %0d", pass_count);
        $display("  Failed:      %0d", fail_count);
        $display("========================================================");
        
        if (fail_count == 0) begin
            $display("  ALL TESTS PASSED!");
        end else begin
            $display("  SOME TESTS FAILED - Review results above");
        end
        $display("========================================================\n");

        #10;
        $finish;
    end

endmodule

