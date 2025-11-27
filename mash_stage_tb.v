`timescale 1ns/1ps

// ============================================================================
// Module: mash_stage_tb
// Description:
//   Testbench for the mash_stage module (first-order delta-sigma accumulator)
//
//   Tests:
//     1. Reset functionality
//     2. Small value accumulation (no carry)
//     3. Large value accumulation (with carry)
//     4. Carry-out verification
//     5. Error output verification
// ============================================================================

module mash_stage_tb;

    // -------------------------------------------------------------------------
    // Testbench signals
    // -------------------------------------------------------------------------
    reg         clk;
    reg         rst_n;
    reg  [15:0] in_val;
    wire [15:0] e_out;
    wire        c_out;

    // -------------------------------------------------------------------------
    // Instantiate DUT
    // -------------------------------------------------------------------------
    mash_stage #(
        .WIDTH(16)
    ) dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .in_val (in_val),
        .e_out  (e_out),
        .c_out  (c_out)
    );

    // -------------------------------------------------------------------------
    // Clock generation: 500 MHz = 2 ns period = toggle every 1 ns
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
    integer cycle_count;
    integer carry_count;

    // -------------------------------------------------------------------------
    // Main test stimulus
    // -------------------------------------------------------------------------
    initial begin
        test_num = 0;
        pass_count = 0;
        fail_count = 0;

        $display("\n========================================================");
        $display("  MASH STAGE TESTBENCH");
        $display("========================================================");
        $display("  Testing first-order delta-sigma accumulator");
        $display("  WIDTH = 16 bits");
        $display("========================================================\n");

        // ---------------------------------------------------------------------
        // TEST 1: Reset functionality
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: Reset Functionality", test_num);
        $display("-----------------------------------------------------");
        
        rst_n = 0;
        in_val = 16'hFFFF;  // Set input high during reset
        #10;
        
        if (e_out == 16'd0 && c_out == 1'b0) begin
            $display("  PASS: Outputs are zero during reset");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Outputs not zero during reset (e_out=%h, c_out=%b)", e_out, c_out);
            fail_count = fail_count + 1;
        end
        $display("");

        // Release reset
        rst_n = 1;
        in_val = 16'd0;
        @(posedge clk);

        // ---------------------------------------------------------------------
        // TEST 2: Small value accumulation (no carry expected)
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: Small Value Accumulation", test_num);
        $display("-----------------------------------------------------");
        $display("  Adding 5 repeatedly, should accumulate without carry");
        $display("  Time    in_val    e_out    c_out");
        
        rst_n = 0; @(posedge clk); rst_n = 1;  // Reset accumulator
        in_val = 16'd5;
        carry_count = 0;
        
        repeat (10) begin
            @(posedge clk);
            $display("  %0t    %5d     %5d     %0b", $time, in_val, e_out, c_out);
            if (c_out) carry_count = carry_count + 1;
        end
        
        if (carry_count == 0) begin
            $display("  PASS: No carries generated as expected");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Unexpected carries detected (%0d)", carry_count);
            fail_count = fail_count + 1;
        end
        $display("");

        // ---------------------------------------------------------------------
        // TEST 3: Large value accumulation (force carry)
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: Large Value Accumulation (Force Carry)", test_num);
        $display("-----------------------------------------------------");
        $display("  Adding 0xF000 repeatedly to force carry-out");
        $display("  Time    in_val    e_out    c_out");
        
        rst_n = 0; @(posedge clk); rst_n = 1;  // Reset accumulator
        in_val = 16'hF000;
        carry_count = 0;
        
        repeat (5) begin
            @(posedge clk);
            $display("  %0t    %5h     %5h     %0b", $time, in_val, e_out, c_out);
            if (c_out) carry_count = carry_count + 1;
        end
        
        if (carry_count > 0) begin
            $display("  PASS: Carries generated as expected (%0d/5)", carry_count);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: No carries detected when expected");
            fail_count = fail_count + 1;
        end
        $display("");

        // ---------------------------------------------------------------------
        // TEST 4: Exact overflow test
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: Exact Overflow Test", test_num);
        $display("-----------------------------------------------------");
        $display("  Testing exact 16-bit overflow behavior");
        $display("  Note: c_out is now combinational, reflects current sum carry");
        
        rst_n = 0; @(posedge clk); rst_n = 1;  // Reset accumulator
        
        // Add 0x8000 twice - should overflow exactly
        in_val = 16'h8000;
        @(posedge clk);
        #0.1;  // Small delay to let combinational outputs settle
        $display("  After 1st 0x8000: e_out=%h, c_out=%b", e_out, c_out);
        // e_out=0x8000, c_out=1 (since 0x8000+0x8000 will overflow)
        
        @(posedge clk);
        #0.1;  // Small delay to let combinational outputs settle
        $display("  After 2nd 0x8000: e_out=%h, c_out=%b", e_out, c_out);
        // e_out=0x0000 (wrapped around), c_out=0 (since 0x0000+0x8000 won't overflow)
        
        // With combinational c_out, after 2nd addition we see e_out=0x0000
        // and c_out reflects the NEXT sum (0x0000+0x8000), which doesn't carry
        // But we can verify overflow occurred by checking e_out wrapped to 0
        if (e_out == 16'h0000) begin
            $display("  PASS: Exact overflow detected (e_out wrapped to 0x0000)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Overflow not detected correctly (got e_out=%h)", e_out);
            fail_count = fail_count + 1;
        end
        $display("");

        // ---------------------------------------------------------------------
        // TEST 5: Alternating input pattern
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: Alternating Input Pattern", test_num);
        $display("-----------------------------------------------------");
        $display("  Alternating between 0x0001 and 0xFFFF");
        $display("  Time    in_val    e_out    c_out");
        
        rst_n = 0; @(posedge clk); rst_n = 1;  // Reset accumulator
        carry_count = 0;
        
        for (cycle_count = 0; cycle_count < 8; cycle_count = cycle_count + 1) begin
            in_val = (cycle_count % 2 == 0) ? 16'h0001 : 16'hFFFF;
            @(posedge clk);
            $display("  %0t    %5h     %5h     %0b", $time, in_val, e_out, c_out);
            if (c_out) carry_count = carry_count + 1;
        end
        
        if (carry_count > 0) begin
            $display("  PASS: Alternating pattern produced carries (%0d/8)", carry_count);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Alternating pattern should produce carries");
            fail_count = fail_count + 1;
        end
        $display("");

        // ---------------------------------------------------------------------
        // TEST 6: Fractional input (typical use case)
        // ---------------------------------------------------------------------
        test_num = test_num + 1;
        $display("TEST %0d: Fractional Input (Typical Use Case)", test_num);
        $display("-----------------------------------------------------");
        $display("  Input = 32768 (0.5 fractional)");
        $display("  Should produce carry approximately 50%% of the time");
        
        rst_n = 0; @(posedge clk); rst_n = 1;  // Reset accumulator
        in_val = 16'd32768;  // Exactly 0.5
        
        carry_count = 0;
        
        repeat (20) begin
            @(posedge clk);
            if (c_out) carry_count = carry_count + 1;
        end
        
        $display("  Carry count over 20 cycles: %0d", carry_count);
        if (carry_count >= 8 && carry_count <= 12) begin
            $display("  PASS: Carry rate approximately 50%% (%0d/20)", carry_count);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Carry rate not close to 50%% (%0d/20)", carry_count);
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

