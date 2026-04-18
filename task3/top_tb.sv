`include "design.sv"

module top_tb;

    bit         clk;
    bit         rst_n;

    logic       en;
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
        $dumpvars();
    end

    always #5 clk = ~clk;

    `ifdef VERILATOR
    always begin // workaround
    `else
    initial begin
    `endif
        $display("%3d | sim started", $time);

        apply_reset();

        wait(rst_n == 1);

        repeat (3) begin
            test_no++;
            write_data($urandom_range(0, 255));
            check_output();
        end

        test_no++;
        hold_data($urandom_range(0, 255));
        check_output();

        repeat (10) begin
            test_no++;
            if ($urandom_range(0, 1))
                write_data($urandom_range(0, 255));
            else
                hold_data($urandom_range(0, 255));
            check_output();
        end

        $display(
            "%3d | report       | total=%0d pass=%0d fail=%0d", 
            $time, test_no, pass_cnt, fail_cnt
        );
        $display("%3d | sim finished", $time);

        $finish;
    end

    task automatic apply_reset();
        en <= 0;
        din <= 0;
        expected_dout <= 0;

        repeat (3) @(posedge clk);

        rst_n = 1;
    endtask

    task automatic write_data (
        input logic [7:0] data
    );
        en <= 1;
        din <= data;
        @(posedge clk);
        expected_dout <= data;
    endtask

    task automatic hold_data (
        input logic [7:0] data
    );
        en <= 0;
        din <= data;
        @(posedge clk);
    endtask

    task automatic check_output();
        if (dout == expected_dout) begin
            pass_cnt++;
            $display(
                "%3d | test %2d PASS | i=%2H o=%2H en=%1d ex=%2H", 
                $time, test_no, din, dout, en, expected_dout
            );
        end else begin
            fail_cnt++;
            $display(
                "%3d | test %2d FAIL | i=%2H o=%2H en=%1d ex=%2H", 
                $time, test_no, din, dout, en, expected_dout
            );
        end
    endtask

endmodule
