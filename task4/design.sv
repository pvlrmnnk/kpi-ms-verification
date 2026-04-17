module regfile4 (
    input logic clk,
    input logic rst_n, // active-low synchronous reset
    input logic we, // write enable
    input logic [1:0] addr, // 2-bit address: 0..3
    input logic [7:0] din, // write data
    output logic [7:0] dout // read data (combinational)
);

    logic [7:0] mem [0:3];

    always_ff @(posedge clk or negedge rst_n) begin
        integer i;
        if (!rst_n) begin
            for (i = 0; i < 4; i = i + 1)
                mem[i] <= 8'h00;
            end else if (we) begin
                mem[addr] <= din;
            end
    end

    always_comb begin
        if (we)
            dout = 8'h00;
        else
            dout = mem[addr];
    end

endmodule
