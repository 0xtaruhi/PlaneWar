/*
 * Description  : 
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-07 17:59:10
 * LastEditTime : 2021-11-21 13:11:46
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\enemy_top.v
 */
`include "../header/define.v"
module enemy_top (
    input  wire                        clk_run,
    input  wire                        clk_vga,
    input  wire                        rst,
    input  wire                        en_i,
    input  wire [     `RAND_WIDTH-1:0] rand_i,
    input  wire                        v_sync_i,
    input  wire [     `H_DISP_LEN-1:0] req_x_addr_i,
    input  wire [     `V_DISP_LEN-1:0] req_y_addr_i,
    input  wire                        crash_enemy_bullet_i,
    input  wire                        crash_me_enemy_i,
    input  wire                        bomb_i,

    output wire                        vga_alpha_o,
    output wire [`COLOR_RGB_DEPTH-1:0] vga_rgb_o
);

    wire                        vga_alpha_enemy1_slow;
    wire [`COLOR_RGB_DEPTH-1:0] vga_rgb_enemy1_slow;
    wire                        vga_alpha_enemy2;
    wire [`COLOR_RGB_DEPTH-1:0] vga_rgb_enemy2;
    wire                        vga_alpha_enemy3;
    wire [`COLOR_RGB_DEPTH-1:0] vga_rgb_enemy3;


    enemy1_slow enemy1_slow_dut
    (
        .clk_run(clk_run),
        .clk_vga(clk_vga),
        .rst(rst),
        .en_i(en_i),
        .rand_i(rand_i),
        .v_sync_i(v_sync_i),
        .req_x_addr_i(req_x_addr_i),
        .req_y_addr_i(req_y_addr_i),
        .crash_enemy_bullet_i(crash_enemy_bullet_i & vga_alpha_enemy1_slow),
        .crash_me_enemy_i(crash_me_enemy_i & vga_alpha_enemy1_slow),
        .bomb_i(bomb_i),
        .vga_alpha_o(vga_alpha_enemy1_slow),
        .vga_rgb_o(vga_rgb_enemy1_slow)
    );

    enemy2 enemy2_dut
    (
        .clk_run(clk_run),
        .clk_vga(clk_vga),
        .rst(rst),
        .en_i(en_i),
        .rand_i(rand_i),
        .v_sync_i(v_sync_i),
        .req_x_addr_i(req_x_addr_i),
        .req_y_addr_i(req_y_addr_i),
        .crash_enemy_bullet_i(crash_enemy_bullet_i & vga_alpha_enemy2),
        .crash_me_enemy_i(crash_me_enemy_i & vga_alpha_enemy2),
        .bomb_i(bomb_i),
        .vga_alpha_o(vga_alpha_enemy2),
        .vga_rgb_o(vga_rgb_enemy2)
    );

    enemy3 enemy3_dut
    (
        .clk_run(clk_run),
        .clk_vga(clk_vga),
        .rst(rst),
        .en_i(en_i),
        .rand_i(rand_i),
        .v_sync_i(v_sync_i),
        .req_x_addr_i(req_x_addr_i),
        .req_y_addr_i(req_y_addr_i),
        .crash_enemy_bullet_i(crash_enemy_bullet_i & vga_alpha_enemy3),
        .crash_me_enemy_i(crash_me_enemy_i & vga_alpha_enemy3),
        .bomb_i(bomb_i),
        .vga_alpha_o(vga_alpha_enemy3),
        .vga_rgb_o(vga_rgb_enemy3)
    );

    assign vga_alpha_o = vga_alpha_enemy1_slow | vga_alpha_enemy2 | vga_alpha_enemy3;
    assign vga_rgb_o = vga_alpha_enemy1_slow ? vga_rgb_enemy1_slow : 
                       vga_alpha_enemy2 ? vga_rgb_enemy2 : 
                       vga_alpha_enemy3 ? vga_rgb_enemy3 : 0;
endmodule //enemy_top