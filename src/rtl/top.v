/*
 * Description  : Top file of the project
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 18:54:01
 * LastEditTime : 2021-11-02 14:36:30
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\top.v
 */

`include "../header/define.v"
module top (
        input  wire clk,
        input  wire rst,
        output wire  [`COLOR_R_DEPTH-1:0] vga_r_o,
        output wire  [`COLOR_G_DEPTH-1:0] vga_g_o,
        output wire  [`COLOR_B_DEPTH-1:0] vga_b_o,
        output wire                      h_sync_o,
        output wire                      v_sync_o
    );

    wire clk_40MHz;
    wire clk_60Hz;
    // clk_wiz_0 clk_wiz_0_dut(.clk_i(clk), .clk_40MHz(clk_40MHz));
    clk_mgr
        clk_mgr_dut(.clk(clk),
                    .rst(rst),
                    .clk_40MHz(clk_40MHz),
                    .clk_60Hz(clk_60Hz)
                   );
    wire clk_vga;
    assign clk_vga = clk_40MHz;

    disp_controller
        disp_controller_dut (
            .clk (clk_vga ),
            .vga_r_o (vga_r_o ),
            .vga_g_o (vga_g_o ),
            .vga_b_o (vga_b_o ),
            .h_sync_o (h_sync_o ),
            .v_sync_o  ( v_sync_o)
        );


endmodule //top
