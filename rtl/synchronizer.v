// synchronizer

`default_nettype none
module synchronizer #(
    parameter integer     WIDTH = 1,
    parameter integer     STEP  = 2,
    parameter [WIDTH-1:0] INIT = 0
)(
    input  wire             i_clk,
    input  wire             i_rst_n,

    input  wire [WIDTH-1:0] i_async,
    output wire [WIDTH-1:0] o_sync
);
    (* ASYNC_REG = "TRUE" *)
    reg [WIDTH-1:0] async_ff [STEP-1:0];

    integer i;
    always @(posedge i_clk) begin
        for (i = 0; i < STEP; i = i+1) begin
            if (!i_rst_n) begin
                async_ff[i] <= INIT;
            end
            else begin
                if (i == 0) begin
                    async_ff[i] <= i_async;
                end
                else begin
                    async_ff[i] <= async_ff[i-1];
                end
            end
        end
    end

    assign o_sync = async_ff[STEP-1];

endmodule
`default_nettype wire
