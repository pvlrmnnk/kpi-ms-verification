`include "design.sv"

module top_tb;

    bit clk;
    bit rst_n;

    logic       we;
    logic [1:0] addr;
    logic [7:0] din;
    wire  [7:0] dout;

    regfile4 dut (
        .clk(clk),
        .rst_n(rst_n),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    typedef struct packed {
        logic       we;
        logic [1:0] addr;
        logic [7:0] din;
        logic [7:0] dout;
    } tr_t;

    tr_t tr_queue[$];

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

    `ifdef VERILATOR
        always begin
    `else
        initial begin
    `endif
        fork
            run_clock();
            run_rst();
            run_monitor();
            run_checker();
        join_none

        we <= 0;
        addr <= 0;
        din <= 0;

        wait(rst_n == 1);

        repeat (30) begin
            @(posedge clk);
            do_drive();
        end

        $finish;
    end

    task automatic run_clock();
        forever #5 clk = ~clk;
    endtask

    task automatic run_rst();
        repeat (3) @(posedge clk);
        rst_n = 1;
    endtask

    task automatic do_drive();
        we <= $urandom_range(0, 1);
        addr <= $urandom_range(0, 3);
        din <= $urandom_range(0, 255);
    endtask

    task automatic run_monitor();
        wait(rst_n == 1);

        forever begin
            tr_queue.push_back('{
                we: we, 
                addr: addr,
                din: din,
                dout: dout
            });
            @(posedge clk);
        end
    endtask

    task automatic run_checker();
        logic [7:0] ref_mem [0:3];
        logic [7:0] expected_dout;
        tr_t        tr;
        int         test_no;

        forever begin
            wait(tr_queue.size() > 0);
            test_no++;
            tr = tr_queue.pop_front();
            if (tr.we == 1) 
                ref_mem[tr.addr] = tr.din;
            if (tr.we == 1)
                expected_dout = 0;
            else
                expected_dout = ref_mem[tr.addr];

            if (tr.dout == expected_dout)
                $display(
                    "%5d | Test %2d PASS | we=%0d addr=%H din=%H dout=%H ex_dout=%H", 
                    $time, test_no, tr.we, tr.addr, tr.din, tr.dout, expected_dout
                );
            else
                $display(
                    "%5d | Test %2d FAIL | we=%0d addr=%H din=%H dout=%H ex_dout=%H", 
                    $time, test_no, tr.we, tr.addr, tr.din, tr.dout, expected_dout
                );
        end
    endtask

endmodule
