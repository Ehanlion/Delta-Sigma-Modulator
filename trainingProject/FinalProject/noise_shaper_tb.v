`timescale 1ns/1ps

module noise_shaper_tb;

    // Testbench signals
    reg         clk;
    reg         rst_n;
    reg         c1;
    reg         c2;
    reg         c3;
    wire signed [3:0] out_f;

    // Instantiate DUT
    noise_shaper dut (
        .clk  (clk),
        .rst_n(rst_n),
        .c1   (c1),
        .c2   (c2),
        .c3   (c3),
        .out_f(out_f)
    );

    // 500 MHz clock (2 ns period, toggle every 1 ns)
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    // Stimulus
    initial begin
        $display(" time   c1 c2 c3   out_f");

        // Initialize
        rst_n = 0;
        c1 = 0;
        c2 = 0;
        c3 = 0;

        // Hold reset a bit
        #5;
        rst_n = 1;

        // -------------------------------------------------------------
        // TEST 1: all zeros
        // Expect out_f ≈ 0 for all cycles
        // -------------------------------------------------------------
        $display("\nTEST 1: c1=c2=c3=0");
        repeat (8) begin
            @(posedge clk);
            $display("%5t   %0b  %0b  %0b    %0d", $time, c1, c2, c3, out_f);
        end

        // -------------------------------------------------------------
        // TEST 2: DC on c1 (c1=1, c2=c3=0)
        // Expect out_f to settle to a positive constant
        // -------------------------------------------------------------
        $display("\nTEST 2: c1=1, c2=c3=0");
        c1 = 1;
        c2 = 0;
        c3 = 0;
        repeat (10) begin
            @(posedge clk);
            $display("%5t   %0b  %0b  %0b    %0d", $time, c1, c2, c3, out_f);
        end

        // -------------------------------------------------------------
        // TEST 3: pulse on c2
        // Briefly toggle c2 to see a transient in out_f from the
        // (c2[n-1] - c2[n]) term.
        // -------------------------------------------------------------
        $display("\nTEST 3: pulsing c2");
        c1 = 0;
        c2 = 0;
        c3 = 0;
        repeat (3) begin
            @(posedge clk);
            $display("%5t   %0b  %0b  %0b    %0d", $time, c1, c2, c3, out_f);
        end

        // Single pulse on c2
        c2 = 1;
        @(posedge clk);
        $display("%5t   %0b  %0b  %0b    %0d", $time, c1, c2, c3, out_f);

        c2 = 0;
        repeat (5) begin
            @(posedge clk);
            $display("%5t   %0b  %0b  %0b    %0d", $time, c1, c2, c3, out_f);
        end

        // -------------------------------------------------------------
        // TEST 4: pulse on c3
        // Should create a slightly “richer” transient from the
        // (c3[n-2] - 2*c3[n-1] + c3[n]) term.
        // -------------------------------------------------------------
        $display("\nTEST 4: pulsing c3");
        c1 = 0;
        c2 = 0;
        c3 = 0;
        repeat (3) begin
            @(posedge clk);
            $display("%5t   %0b  %0b  %0b    %0d", $time, c1, c2, c3, out_f);
        end

        c3 = 1;
        @(posedge clk);
        $display("%5t   %0b  %0b  %0b    %0d", $time, c1, c2, c3, out_f);

        c3 = 0;
        repeat (6) begin
            @(posedge clk);
            $display("%5t   %0b  %0b  %0b    %0d", $time, c1, c2, c3, out_f);
        end

        $display("\nSimulation complete.");
        #10;
        $stop;
    end

endmodule
