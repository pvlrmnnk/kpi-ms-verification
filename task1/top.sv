// CASE_A CASE_B CASE_C CASE_D
`define CASE_A
//`define MISTAKE_NO_INIT

module top;

    // #1 module and signal declaration
    logic       clk;
    logic [3:0] counter;
    logic       sig_a;
    wire        sig_b;
    logic       sig_c;
    logic       sig_d;
    
    // #2 waveform dump
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

    // #3 continusos assignment
    assign sig_b = sig_a;

    // #4 start and finish
    initial begin
        $display("%d | sim start", $time);
        #60 $display("%d | sim finish", $time);
        $finish;
    end

    // #5 manual signal control
    initial begin
        sig_a = 0;
        $display("%d | step_5 | sig_a=%d sig_b=%d", $time, sig_a, sig_b);
        #10 sig_a = 1;
        $display("%d | step_5 | sig_a=%d sig_b=%d", $time, sig_a, sig_b);
        #10 sig_a = 0;
        $display("%d | step_5 | sig_a=%d sig_b=%d", $time, sig_a, sig_b);
    end

    // #6 clock generation
    initial clk = 0;

    always begin
        #5 clk = ~clk;
        $display("%d | step_6 | clk=%d ", $time, clk);
    end

    // #7,8,9,10 magic with assignments
    initial begin
        `ifndef MISTAKE_NO_INIT
        sig_c = 0;
        sig_d = 0;
        `endif
    end

    // CASE_A CASE_B CASE_C CASE_D
    `define CASE_A

    initial begin
        `ifdef CASE_A
        $display("%d | CASE_A", $time);
        `elsif CASE_B
        $display("%d | CASE_B", $time);
        `elsif CASE_C
        $display("%d | CASE_C", $time);
        `elsif CASE_D
        $display("%d | CASE_D", $time);
        `endif
    end

    always @(posedge clk) begin
        `ifdef CASE_A
        sig_c = ~sig_c;
        `elsif CASE_B
        sig_d = sig_c;
        `elsif CASE_C
        sig_c <= ~sig_c;
        `elsif CASE_D
        sig_d <= sig_c;
        `endif
        $display("%d | magic_1 | sig_c=%d sig_d=%d", $time, sig_c, sig_d);
    end

    always @(posedge clk) begin
        `ifdef CASE_A
        sig_d = sig_c;
        `elsif CASE_B
        sig_c = ~sig_c;
        `elsif CASE_C
        sig_d <= sig_c;
        `elsif CASE_D
        sig_c <= ~sig_c;
        `endif
        $display("%d | magic_2 | sig_c=%d sig_d=%d", $time, sig_c, sig_d);
    end

    // #11 counter
    initial begin
        counter = 0;

        repeat (5) begin
            #10 counter++;
            $display("%d | counter | counter=%0d", $time, counter);
        end
    end

endmodule
