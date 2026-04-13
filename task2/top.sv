/* verilator lint_off UNUSEDSIGNAL */
`include "reg8.sv"

module top;

    logic clk;
    logic rst_n;
    logic en;
    logic [7:0] din;
    wire  [7:0] dout;

    typedef enum { FAIL, PASS } status_e;

    status_e    status;
    logic [7:0] prev_dout;
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
        $display("%d | sim started", $time);
        #200 $display("%d | sim finished", $time);
        $finish;
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
    end

    initial begin
        test_no = 0;
        expected_dout = 8'h00;
        en = 0;
        din = 0;
        pass_cnt = 0;
        fail_cnt = 0;

        @(posedge rst_n);

        repeat (3) begin
            test_no++;
            expected_dout = $urandom_range(0, 255)[7:0];
            en = 1;
            din = expected_dout;
            @(posedge clk);
            if (dout == expected_dout) begin 
                pass_cnt++;
                status = PASS;
            end else begin
                fail_cnt++;
                status = FAIL;
            end
            $display("%d | test %0d %s | i=%0d o=%0d en=%0d ex=%0d", $time, test_no, status.name, din, dout, en, expected_dout);
        end

        test_no++;
        expected_dout = dout;
        en = 0;
        din = $urandom_range(0, 255)[7:0];
        @(posedge clk);
        if (dout == expected_dout) begin 
            pass_cnt++;
            status = PASS;
        end else begin
            fail_cnt++;
            status = FAIL;
        end
        $display("%d | test %0d %s | i=%0d o=%0d en=%0d ex=%0d", $time, test_no, status.name, din, dout, en, expected_dout);

        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        
        repeat (10) begin
            test_no++;
            prev_dout = dout;
            en = $urandom_range(0, 1)[0];
            din = $urandom_range(0, 255)[7:0];
            expected_dout = en ? din : prev_dout;
            @(posedge clk);
                if (dout == expected_dout) begin 
                pass_cnt++;
                status = PASS;
            end else begin
                fail_cnt++;
                status = FAIL;
            end
            $display("%d | test %0d %s | i=%0d o=%0d en=%0d ex=%0d", $time, test_no, status.name, din, dout, en, expected_dout);
        end

        $display("%d | report | total=%0d pass=%0d fail=%0d", $time, test_no, pass_cnt, fail_cnt);
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule
