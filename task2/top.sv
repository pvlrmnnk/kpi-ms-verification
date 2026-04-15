`include "reg8.sv"

module top;

    logic clk;
    logic rst_n;
    logic en;
    logic [7:0] din;
    wire  [7:0] dout;

    logic [7:0] expected_dout;
    int         pass_cnt;
    int         fail_cnt;
    int         test_no;

    reg8 dut(
        .clk (clk),
        .rst_n (rst_n),
        .en (en),
        .din (din),
        .dout (dout)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

    initial begin
        $display("%d | sim started", $time);
        #200 $display("%d | sim finished", $time);
        $finish;
    end

    `ifdef VERILATOR
    always begin // workaround
    `elsif
    initial begin
    `endif
        clk <= 0;
        forever #5 clk <= ~clk;
    end

    `ifdef VERILATOR
    always begin // workaround
    `elsif
    initial begin
    `endif
        rst_n <= 0;
        repeat (3) @(posedge clk);
        rst_n <= 1;

        `ifdef VERILATOR
        wait(0); // workaround
        `endif
    end

    `ifdef VERILATOR
    always begin // workaround
    `elsif
    initial begin
    `endif
        test_no = 0;
        pass_cnt = 0;
        fail_cnt = 0;

        expected_dout <= 0;
        en <= 0;
        din <= 0;

        wait(rst_n == 1);

        repeat (3) begin
            test_no++;
            en <= 1;
            din <= $urandom_range(0, 255);
            @(posedge clk);
            expected_dout <= din;
            if (dout == expected_dout) begin 
                pass_cnt++;
                $display("%d | test %0d PASS | i=%0d o=%0d en=%0d ex=%0d", $time, test_no, din, dout, en, expected_dout);
            end else begin
                fail_cnt++;
                $display("%d | test %0d FAIL | i=%0d o=%0d en=%0d ex=%0d", $time, test_no, din, dout, en, expected_dout);
            end
        end

        test_no++;
        en <= 0;
        din <= $urandom_range(0, 255);
        @(posedge clk);
        if (dout == expected_dout) begin 
            pass_cnt++;
            $display("%d | test %0d PASS | i=%0d o=%0d en=%0d ex=%0d", $time, test_no, din, dout, en, expected_dout);
        end else begin
            fail_cnt++;
            $display("%d | test %0d FAIL | i=%0d o=%0d en=%0d ex=%0d", $time, test_no, din, dout, en, expected_dout);
        end
        
        repeat (10) begin
            test_no++;
            en <= $urandom_range(0, 1);
            din <= $urandom_range(0, 255);
            @(posedge clk);
            expected_dout <= en ? din : expected_dout;
            if (dout == expected_dout) begin 
                pass_cnt++;
                $display("%d | test %0d PASS | i=%0d o=%0d en=%0d ex=%0d", $time, test_no, din, dout, en, expected_dout);
            end else begin
                fail_cnt++;
                $display("%d | test %0d FAIL | i=%0d o=%0d en=%0d ex=%0d", $time, test_no, din, dout, en, expected_dout);
            end
        end

        $display("%d | report | total=%0d pass=%0d fail=%0d", $time, test_no, pass_cnt, fail_cnt);

        `ifdef VERILATOR
        wait(0); // workaround
        `endif
    end

endmodule
