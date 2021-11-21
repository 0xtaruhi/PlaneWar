/*
 * Description  : bomb, double shoot
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-21 11:17:32
 * LastEditTime : 2021-11-21 13:05:10
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\bonus.v
 */
`include "../header/define.v"
module bonus (
    input  wire                        clk_run,
    input  wire                        clk_vga,
    input  wire                        rst,
    input  wire                        en_i,
    input  wire [     `RAND_WIDTH-1:0] rand_i,
    input  wire                        v_sync_i,
    input  wire [     `H_DISP_LEN-1:0] req_x_addr_i,
    input  wire [     `V_DISP_LEN-1:0] req_y_addr_i,
    input  wire                        crash_me_bonus_i,

    output wire                        vga_alpha_o,
    output wire [`COLOR_RGB_DEPTH-1:0] vga_rgb_o
);

    wire                        vga_alpha_bomb;
    wire [`COLOR_RGB_DEPTH-1:0] vga_rgb_bomb;

    bomb bomb_dut
    (
        .clk_run(clk_run),
        .clk_vga(clk_vga),
        .rst(rst),
        .en_i(en_i),
        .rand_i(rand_i),
        .v_sync_i(v_sync_i),
        .req_x_addr_i(req_x_addr_i),
        .req_y_addr_i(req_y_addr_i),
        .crash_me_bonus_i(crash_me_bonus_i & vga_alpha_bomb),
        .vga_alpha_o(vga_alpha_bomb),
        .vga_rgb_o(vga_rgb_bomb)
    );

    assign vga_alpha_o = vga_alpha_bomb;
    assign vga_rgb_o = vga_alpha_bomb ? vga_rgb_bomb : 0;

endmodule //bonus