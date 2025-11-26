`timescale 1ns/1ps

module M216A_Testbench;

    // -------------------------------------------------------------------------
    // DUT I/O signals (top-level MASH modulator)
    // -------------------------------------------------------------------------
    reg         clk;
    reg         rst_n;
    reg  [3:0]  in_i;
    reg  [15:0] in_f;
    wire [3:0]  out;

    // Instantiate the DUT
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

    // Number of cycles to average for each test
    integer N_CYCLES;

    // -------------------------------------------------------------------------
    // Optional: VCD dump for waveform viewing or power analysis
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("M216A_TopModule.vcd");
        $dumpvars(0, M216A_Testbench);
    end

    // -------------------------------------------------------------------------
    // Task: run_avg_test
    //   - Applies (ti, tf) as (in_i, in_f)
    //   - Waits a few warm-up cycles
    //   - Averages 'out' over 'cycles' cycles
    //   - Computes expected average = ti + tf / 65536.0
    //   - Prints measured vs expected
    // -------------------------------------------------------------------------
    task run_avg_test;
        input  [3:0]  ti;
        input  [15:0] tf;
        input  integer cycles;
        begin
            in_i = ti;
            in_f = tf;

            // Reset sum
            sum_out = 0;

            // Let the modulator settle a bit after changing inputs
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

            $display("-----------------------------------------------------");
            $display("Test: in_i = %0d, in_f = %0d", ti, tf);
            $display("Cycles averaged   : %0d", cycles);
            $display("Sum of out        : %0d", sum_out);
            $display("Expected average  : %0f", expected_avg);
            $display("Measured average  : %0f", avg_out);
            $display("Error (meas-exp)  : %0f", error);
            $display("-----------------------------------------------------\n");
        end
    endtask

    // -------------------------------------------------------------------------
    // Extra instance of noise_shaper for randomized carry injection test
    //   - We don't use the DUT's internal carries here
    //   - Instead, we directly drive random c1/c2/c3 into a separate
    //     noise_shaper instance (ns_rand) and confirm out_f stays in [-3..+4].
    // -------------------------------------------------------------------------
    reg        c1_rand, c2_rand, c3_rand;
    wire signed [3:0] out_f_rand;

    noise_shaper ns_rand (
        .clk  (clk),
        .rst_n(rst_n),
        .c1   (c1_rand),
        .c2   (c2_rand),
        .c3   (c3_rand),
        .out_f(out_f_rand)
    );

    integer i_rand;
    integer N_RAND;
    integer violations;

    // -------------------------------------------------------------------------
    // Main stimulus and tests
    // -------------------------------------------------------------------------
    initial begin
        // ---------------------------------------------------------------------
        // Global reset and defaults
        // ---------------------------------------------------------------------
        rst_n = 1'b0;
        in_i  = 4'd0;
        in_f  = 16'd0;
        c1_rand = 1'b0;
        c2_rand = 1'b0;
        c3_rand = 1'b0;

        N_CYCLES = 5000;  // default averaging window

        // Hold reset low for a few ns
        #5;
        rst_n = 1'b1;

        // ---------------------------------------------------------------------
        // 1) Multi-input tests (including your original 8, 32000 case)
        // ---------------------------------------------------------------------
        $display("\n=== MULTI-INPUT AVERAGE TESTS ===\n");

        // Original test: in_i = 8, in_f = 32000  (~8.488)
        run_avg_test(4'd8, 16'd32000, N_CYCLES);

        // Another mid-range test: 4.5 = 4 + 0.5 -> in_i=4, in_f=32768
        run_avg_test(4'd4, 16'd32768, N_CYCLES);

        // Small fractional offset: ~7.015
        run_avg_test(4'd7, 16'd1000, N_CYCLES);

        // Near integer: in_i=5, in_f=100 -> ~5.0015
        run_avg_test(4'd5, 16'd100, N_CYCLES);

        // ---------------------------------------------------------------------
        // 2) Extreme edge tests
        //     - Lowest legal input:  in_i=3, in_f=0   -> expected 3.0
        //     - Highest legal input: in_i=11, in_f=65535 -> ~11.9999847
        // ---------------------------------------------------------------------
        $display("\n=== EXTREME EDGE TESTS ===\n");

        run_avg_test(4'd3, 16'd0, N_CYCLES);          // lower edge
        run_avg_test(4'd11, 16'hFFFF, N_CYCLES);      // upper edge

        // ---------------------------------------------------------------------
        // 3) Randomized carry injection test for noise_shaper
        //
        // This does NOT use the DUT's internal carries; instead it probes a
        // separate noise_shaper instance (ns_rand) with random c1/c2/c3 to
        // ensure out_f_rand always remains within [-3..+4].
        // ---------------------------------------------------------------------
        $display("\n=== RANDOMIZED CARRY INJECTION TEST (noise_shaper) ===\n");

        N_RAND    = 10000;
        violations = 0;

        // Re-assert reset briefly for a clean start on ns_rand
        rst_n = 1'b0;
        @(posedge clk);
        rst_n = 1'b1;

        // Initialize random carries
        c1_rand = 1'b0;
        c2_rand = 1'b0;
        c3_rand = 1'b0;

        // Run random test
        for (i_rand = 0; i_rand < N_RAND; i_rand = i_rand + 1) begin
            @(posedge clk);

            // Randomize c1_rand, c2_rand, c3_rand (0 or 1)
            c1_rand = $random & 1;
            c2_rand = $random & 1;
            c3_rand = $random & 1;

            // Check that out_f_rand stays within expected bounds [-3..+4]
            if ((out_f_rand > 4) || (out_f_rand < -3)) begin
                violations = violations + 1;
                $display("Violation at time %0t: c1=%0b c2=%0b c3=%0b out_f_rand=%0d",
                         $time, c1_rand, c2_rand, c3_rand, out_f_rand);
            end
        end

        $display("Random carry test: N_RAND = %0d, violations = %0d", N_RAND, violations);
        if (violations == 0)
            $display("Result: All random outputs stayed within [-3..+4].");
        else
            $display("Result: Some outputs exceeded expected range.");

        // ---------------------------------------------------------------------
        // Done
        // ---------------------------------------------------------------------
        $display("\nAll tests completed.\n");
        #10;
        $stop;
    end

endmodule
