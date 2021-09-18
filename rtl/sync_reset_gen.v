
`default_nettype none
module sync_reset_gen (
    input  wire i_clk,

    input  wire i_rst_n,
    output wire o_rst_n
);
    (* ASYNC_REG = "TRUE" *)
    reg [ 1: 0] sync_rst;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            sync_rst <= 2'b00;
        end
        else begin
            sync_rst <= {sync_rst[0], 1'b1};
        end
    end

    assign o_rst_n = sync_rst[1];

endmodule
`default_nettype wire
