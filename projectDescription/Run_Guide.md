# Run Guide

## Simulation (ModelSim/QuestaSim)

To run the verification simulations:

1.  **Setup Environment**:
    Source the tool setup script to load ModelSim and Synopsys tools:
    ```bash
    source ../../tool-setup
    ```

2.  **Navigate** to the project directory:
    ```bash
    cd deltaSigmaProject/trainingProject/FinalProject
    ```

2.  **Compile** the source files:
    ```bash
    vlog mash_stage.v noise_shaper.v M216A_TopModule.v M216A_Testbench.v
    ```

3.  **Simulate** the testbench:
    ```bash
    vsim work.M216A_Testbench
    ```
    *(Or use `vsim -c -do "run -all"` for command line mode)*

4.  **View Results**:
    - Check the transcript for "Multi-input Average Tests" and "Randomized Carry Injection Test" results.
    - Look for "Errors: 0".

## Synthesis & Power (Synopsys)

*Note: These commands run on the server with Synopsys tools installed.*

1.  **Synthesis**:
    ```bash
    dc_shell -f DC_Synthesis.tcl
    ```
    *Ensure you update `DC_Synthesis.tcl` to point to `M216A_TopModule` instead of `alu`.*

2.  **Power Analysis**:
    - First, run the simulation on the synthesized netlist (if verifying gates) or just ensure VCD is generated.
    - Run PrimeTime:
    ```bash
    pt_shell -f PrimeTime_PrimePower.tcl
    ```

