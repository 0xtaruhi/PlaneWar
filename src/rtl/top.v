/*
 * Description  : Top file of the project
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 18:54:01
 * LastEditTime : 2021-11-03 22:41:26
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\top.v
 */

`include "../header/define.v"
module top (
        input  wire                       clk,
        input  wire                       rst,

        input  wire                       btn_u_pin_i,      // buttons on the board
        input  wire                       btn_d_pin_i,
        input  wire                       btn_l_pin_i,
        input  wire                       btn_r_pin_i,

        output wire  [`COLOR_R_DEPTH-1:0] vga_r_o,
        output wire  [`COLOR_G_DEPTH-1:0] vga_g_o,
        output wire  [`COLOR_B_DEPTH-1:0] vga_b_o,
        output wire                       h_sync_o,
        output wire                       v_sync_o
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
    wire clk_run;
    assign clk_run = clk_60Hz;

    wire [`COLOR_RGB_DEPTH-1:0] me_rgb;
    wire                        me_alpha;
    wire [     `H_DISP_LEN-1:0] req_x_addr;
    wire [     `V_DISP_LEN-1:0] req_y_addr;
    wire                        disp;

    wire          me_move_en;
    wire [1:0]    me_direct;
    
    enc_btn
        enc_btn_dut(
            .clk(clk_run),
            .btn_r_pin_i(btn_r_pin_i),
            .btn_l_pin_i(btn_l_pin_i),
            .btn_d_pin_i(btn_d_pin_i),
            .btn_u_pin_i(btn_u_pin_i),
            .move_en_o(me_move_en),
            .direct_o(me_direct)
        );

    disp_ctrl
        disp_ctrl_dut (
            .clk_vga (clk_vga ),
            .clk_run (clk_run),
            .rst(rst),
            .me_rgb_i(me_rgb),
            .me_alpha_i(me_alpha),
            .req_x_addr_o(req_x_addr),
            .req_y_addr_o(req_y_addr),
            .vga_r_o (vga_r_o ),
            .vga_g_o (vga_g_o ),
            .vga_b_o (vga_b_o ),
            .h_sync_o (h_sync_o ),
            .v_sync_o  ( v_sync_o),
            .disp_o  (disp)
        );

    me
        me_dut (
            .clk_vga(clk_vga),
            .clk_run(clk_run),
            .rst(rst),
            .en_i(disp),
            .v_sync_i(v_sync_o),
            .req_x_addr_i(req_x_addr),
            .req_y_addr_i(req_y_addr),
            .move_en_i(me_move_en),
            .direct_i(me_direct),
            .vga_rgb_o(me_rgb),
            .vga_alpha_o(me_alpha)
        );

endmodule //top
