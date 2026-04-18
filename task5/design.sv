module regfile4_split_req (
    input logic clk,
    input logic rst_n, // async active-low reset

    // Write channel
    input logic wr_req,
    input logic [1:0] wr_addr,
    input logic [7:0] wr_data,

    // Read channel
    input logic rd_req,
    input logic [1:0] rd_addr,
    output logic [7:0] rd_data
);

    logic [7:0] mem [0:3];

    // Async reset + sync write
    always_ff @(posedge clk or negedge rst_n) begin
        integer i;
        if (!rst_n) begin
            for (i = 0; i < 4; i = i + 1)
                mem[i] <= 8'h00;
        end else if (wr_req) begin
            mem[wr_addr] <= wr_data;
        end
    end

    // Combinational read (only valid when rd_req==1)
    always_comb begin
        if (rd_req)
            rd_data = mem[rd_addr];
        else
            rd_data = 8'h00;
    end

endmodule
