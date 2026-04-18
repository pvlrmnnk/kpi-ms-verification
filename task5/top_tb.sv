`include "design.sv"

interface wr_if;
    logic       wr_req;
    logic [1:0] wr_addr;
    logic [7:0] wr_data;
endinterface

interface rd_if;
    logic       rd_req;
    logic [1:0] rd_addr;
    wire  [7:0] rd_data;
endinterface

module top_tb #(
    parameter int TX_CNT = 100
);

    bit clk;
    bit rst_n;

    wr_if wr_bus();
    rd_if rd_bus();

    regfile4_split_req dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_req(wr_bus.wr_req),
        .wr_addr(wr_bus.wr_addr),
        .wr_data(wr_bus.wr_data),
        .rd_req(rd_bus.rd_req),
        .rd_addr(rd_bus.rd_addr),
        .rd_data(rd_bus.rd_data)
    );

    typedef struct packed {
        logic [1:0] wr_addr;
        logic [7:0] wr_data;
    } wr_tr_t;

    typedef struct packed {
        logic [1:0] rd_addr;
        logic [7:0] rd_data;
    } rd_tr_t;

    mailbox #(wr_tr_t) wr_mbx;
    mailbox #(rd_tr_t) rd_bmx;

    typedef enum { 
        RD_TR,
        WR_TR
    } tr_e;

    tr_e curr_tr;

    int write_cnt;
    int read_cnt;
    int pass_cnt;
    int fail_cnt;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();
    end

    `ifdef VERILATOR
        always begin
    `else
        initial begin
    `endif
        wr_mbx = new();
        rd_bmx = new();

        fork
            run_clock();
            run_rst();
        join_none

        fork
            run_rd_wr_tr_decider();
            run_wr_driver();
            run_rd_driver();
            run_wr_monitor();
            run_rd_monitor();
            run_checker();
        join_any

        repeat (3) @(posedge clk);

        $display(
            "%5d | report | write_cnt=%0d read_cnt=%0d pass_cnt=%0d fail_cnt=%0d", 
            $time, write_cnt, read_cnt, pass_cnt, fail_cnt
        );

        $finish;
    end

    task automatic run_clock();
        forever #5 clk = ~clk;
    endtask

    task automatic run_rst();
        repeat (3) @(posedge clk);
        rst_n = 1;
    endtask

    task automatic run_wr_driver();
        wr_bus.wr_req <= 0;
        wr_bus.wr_addr <= 0;
        wr_bus.wr_data <= 0;

        wait(rst_n);

        repeat (TX_CNT) begin
            if (curr_tr == WR_TR) begin
                wr_bus.wr_req <= 1;
                wr_bus.wr_addr <= $urandom_range(0, 3);
                wr_bus.wr_data <= $urandom_range(0, 255);
            end else begin
                wr_bus.wr_req <= 0;
            end
            @(posedge clk);
        end

        wr_bus.wr_req <= 0;
    endtask

    task automatic run_rd_driver();
        rd_bus.rd_req <= 0;
        rd_bus.rd_addr <= 0;

        wait(rst_n);
        
        repeat (TX_CNT) begin
            if (curr_tr == RD_TR) begin
                rd_bus.rd_req <= 1;
                rd_bus.rd_addr <= $urandom_range(0, 3);
            end else begin
                rd_bus.rd_req <= 0;
            end
            @(posedge clk);
        end

        rd_bus.rd_req <= 0;
    endtask

    task automatic run_rd_wr_tr_decider();
        curr_tr <= RD_TR;

        wait(rst_n);

        repeat (TX_CNT) begin
            if ($urandom_range(0, 1))
                curr_tr <= WR_TR;
            else
                curr_tr <= RD_TR;
            @(posedge clk);
        end
    endtask

    task automatic run_wr_monitor();
        forever begin
            @(posedge clk);
            if (wr_bus.wr_req) begin
                wr_tr_t wr_tr = '{
                    wr_addr: wr_bus.wr_addr,
                    wr_data: wr_bus.wr_data
                };
                wr_mbx.put(wr_tr);
            end
        end
    endtask

    task automatic run_rd_monitor();
        forever begin
            @(posedge clk);
            if (rd_bus.rd_req) begin
                rd_tr_t rd_tr = '{
                    rd_addr: rd_bus.rd_addr,
                    rd_data: rd_bus.rd_data
                };
                rd_bmx.put(rd_tr);
            end
        end
    endtask

    task automatic run_checker();
        logic [7:0] ref_mem [0:3] = '{default: 8'h00};

        wr_tr_t wr_tr;
        rd_tr_t rd_tr;

        forever begin
            #1; // delay
            if (wr_mbx.try_get(wr_tr)) begin
                write_cnt++;
                ref_mem[wr_tr.wr_addr] = wr_tr.wr_data;
            end
            if (rd_bmx.try_get(rd_tr)) begin
                read_cnt++;
                if (ref_mem[rd_tr.rd_addr] == rd_tr.rd_data) begin
                    pass_cnt++;
                end else begin
                    fail_cnt++;
                end
            end
        end
    endtask

endmodule
