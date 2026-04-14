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
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("%d | sim started", $time);

        apply_reset();

        wait (rst_n == 1); // not required in this case actually

        repeat (3) begin
            test_no++;
            write_data($urandom_range(0, 255)[7:0]);
            check_output();
        end

        test_no++;
        hold_data($urandom_range(0, 255)[7:0]);
        check_output();

        repeat (10) begin
            test_no++;
            if ($urandom_range(0, 1) == 1)
                write_data($urandom_range(0, 255)[7:0]);
            else
                hold_data($urandom_range(0, 255)[7:0]);
            check_output();
        end

        $display("%d | report | total=%0d pass=%0d fail=%0d", $time, test_no, pass_cnt, fail_cnt);
        $display("%d | sim finished", $time);
        $finish;
    end

    task automatic apply_reset();
        begin
            rst_n = 0;
            en = 0;
            din = 0;

            test_no = 0;
            expected_dout = 0;
            pass_cnt = 0;
            fail_cnt = 0;

            repeat (3) @(posedge clk);

            rst_n = 1;
        end
    endtask

    task automatic write_data (
        input logic [7:0] data
    );
        begin
            en = 1;
            din = data;
            expected_dout = data;
            @(posedge clk);
        end
    endtask

    task automatic hold_data (
        input logic [7:0] data
    );
        begin
            en = 0;
            din = data;
            @(posedge clk);
        end
    endtask

    task automatic check_output();
        begin
            if (dout == expected_dout) begin
                pass_cnt++;
                $display("%d | test %0d PASS | i=%0d o=%0d en=%0d ex=%0d", $time, test_no, din, dout, en, expected_dout);
            end else begin
                fail_cnt++;
                $display("%d | test %0d FAIL | i=%0d o=%0d en=%0d ex=%0d", $time, test_no, din, dout, en, expected_dout);
            end
        end
    endtask

endmodule
