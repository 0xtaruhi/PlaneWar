/*
 * Description  : 
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 23:00:26
 * LastEditTime : 2021-11-01 23:43:22
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\disp_controller.v
 */
`include "../header/define.v"

module disp_controller (
    input  wire clk,
    // input  wire [`H_DISP_LEN-1   :0] req_h_addr_i,
    // input  wire [`V_DISP_LEN-1   :0] req_v_addr_i,
    // input  wire                      disp_i,             // 正在显示有效内容

    output reg  [`COLOR_R_DEPTH-1:0] vga_r_o,
    output reg  [`COLOR_G_DEPTH-1:0] vga_g_o,
    output reg  [`COLOR_B_DEPTH-1:0] vga_b_o,
    output wire                      h_sync_o,
    output wire                      v_sync_o
);

    wire [`H_DISP_LEN-1:0] req_h_addr;
    wire [`V_DISP_LEN-1:0] req_v_addr;
    wire disp;                          // 正在显示有效内容

    dri_vga dri_vga_dut(
        .clk(clk),
        .en_i(1'b1),
        .h_sync_o(h_sync_o),
        .v_sync_o(v_sync_o),
        .disp_o(disp),
        .req_h_addr_o(req_h_addr),
        .req_v_addr_o(req_v_addr)
    );

    always @(*) begin
        if(disp) begin
            vga_r_o = `BG_COLOR_R;
            vga_g_o = `BG_COLOR_G;
            vga_b_o = `BG_COLOR_B; 
        end else begin
            vga_r_o = `BG_COLOR_R;
            vga_g_o = `BG_COLOR_G;
            vga_b_o = `BG_COLOR_B;
        end
    end

endmodule //disp_controller