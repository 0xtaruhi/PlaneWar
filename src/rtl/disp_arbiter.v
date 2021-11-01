`include "../header/define.v"

module disp_arbiter (
    input  wire clk,
    input  wire [`H_DISP_LEN-1   :0] req_h_addr_i,
    input  wire [`V_DISP_LEN-1   :0] req_v_addr_i,

    output reg  [`COLOR_R_DEPTH-1:0] vga_r_o,
    output reg  [`COLOR_G_DEPTH-1:0] vga_g_o,
    output reg  [`COLOR_B_DEPTH-1:0] vga_b_o
);

    always @(*) begin
        vga_r_o = `BG_COLOR_R;
        vga_g_o = `BG_COLOR_G;
        vga_b_o = `BG_COLOR_B;
    end

endmodule //disp_arbiter