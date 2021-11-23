/*
 * Description  : Top file of the project
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 18:54:01
 * LastEditTime : 2021-11-23 20:40:42
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\top.v
 */

`include "../header/define.v"
module top (
        input  wire                       clk,
        // input  wire                       rst,

        input  wire                       btn_u_pin_i,      // buttons on the board
        input  wire                       btn_d_pin_i,
        input  wire                       btn_l_pin_i,
        input  wire                       btn_r_pin_i,
        input  wire                       btn_c_pin_i,

        // input  wire                       mode_i,

        output wire  [`COLOR_R_DEPTH-1:0] vga_r_o,
        output wire  [`COLOR_G_DEPTH-1:0] vga_g_o,
        output wire  [`COLOR_B_DEPTH-1:0] vga_b_o,
        output wire                       h_sync_o,
        output wire                       v_sync_o
    );

    // wire clk_40MHz;
    // wire clk_60Hz;
    wire                            clk_vga;
    wire                            clk_run;
    wire [         `RAND_WIDTH-1:0] rand;
    // wire                            gameover;
    wire                            gamestart;
    wire [`GAME_STATUS_BIT_LEN-1:0] game_status;
    wire [    `COLOR_RGB_DEPTH-1:0] me_rgb;
    wire                            me_alpha;
    wire [    `COLOR_RGB_DEPTH-1:0] bullet_rgb;
    wire                            bullet_alpha;
    wire [    `COLOR_RGB_DEPTH-1:0] enemy_rgb;
    wire                            enemy_alpha;
    wire [    `COLOR_RGB_DEPTH-1:0] bonus_rgb;
    wire                            bonus_alpha;
    wire                            info_alpha;
    wire [  `OBJ_X_POS_BIT_LEN-1:0] me_x_pos;
    wire [  `OBJ_Y_POS_BIT_LEN-1:0] me_y_pos;
    wire [         `H_DISP_LEN-1:0] req_x_addr;
    wire [         `V_DISP_LEN-1:0] req_y_addr;
    wire                            disp;
    wire                            bomb;
    wire                            crash_me_enemy;
    wire                            crash_enemy_bullet;
    wire                            crash_me_bonus;
    wire                            me_move_en;
    wire [                     1:0] me_direct;
    wire                            shoot_mode;
    wire                            rst;
    wire [`ADD_SCORE_BIT_WIDTH-1:0] add_score;
    wire [    `SCORE_WIDTH_DEC-1:0] score;
    wire [                     1:0] score_digit;
    
    clk_mgr clk_mgr_inst
    (
        .clk(clk),
        .rst(rst),
        .clk_vga(clk_vga),
        .clk_run(clk_run)
    );


    enc_btn enc_btn_inst
    (
        .clk(clk_run),
        .btn_r_pin_i(btn_r_pin_i),
        .btn_l_pin_i(btn_l_pin_i),
        .btn_d_pin_i(btn_d_pin_i),
        .btn_u_pin_i(btn_u_pin_i),
        .btn_c_pin_i(btn_c_pin_i),
        .move_en_o(me_move_en),
        .direct_o(me_direct),
        .rst(rst)
    );

    rand rand_inst
    (
        .clk_vga(clk_vga),
        .rst(rst),
        .data_o(rand)
    );

    game_ctrl game_ctrl_inst
    (
        .clk_vga(clk_vga),
        .rst(rst),
        .me_alpha_i(me_alpha),
        .bullet_alpha_i(bullet_alpha),
        .enemy_alpha_i(enemy_alpha),
        .bonus_alpha_i(bonus_alpha),
        .disp_i(disp),
        .gamestart_i(gamestart),
        .game_status_o(game_status),
        // .bomb_o(bomb),
        .crash_me_enemy_o(crash_me_enemy),
        .crash_enemy_bullet_o(crash_enemy_bullet),
        .crash_me_bonus_o(crash_me_bonus)
    );

    disp_ctrl disp_ctrl_inst
    (
        .clk_vga (clk_vga ),
        .clk_run (clk_run),
        .rst(0),
        .me_rgb_i(me_rgb),
        .me_alpha_i(me_alpha),
        .bullet_rgb_i(bullet_rgb),
        .bullet_alpha_i(bullet_alpha),
        .enemy_rgb_i(enemy_rgb),
        .enemy_alpha_i(enemy_alpha),
        .bonus_rgb_i(bonus_rgb),
        .bonus_alpha_i(bonus_alpha),
        .info_alpha_i(info_alpha),
        .req_x_addr_o(req_x_addr),
        .req_y_addr_o(req_y_addr),
        .vga_r_o (vga_r_o ),
        .vga_g_o (vga_g_o ),
        .vga_b_o (vga_b_o ),
        .h_sync_o (h_sync_o ),
        .v_sync_o  ( v_sync_o),
        .disp_o  (disp)
    );

    me me_inst
    (
        .clk_vga(clk_vga),
        .clk_run(clk_run),
        .rst(rst),
        .en_i(disp),
        .v_sync_i(v_sync_o),
        .req_x_addr_i(req_x_addr),
        .req_y_addr_i(req_y_addr),
        .move_en_i(me_move_en),
        .direct_i(me_direct),
        .x_pos_o(me_x_pos),
        .y_pos_o(me_y_pos),
        .vga_rgb_o(me_rgb),
        .vga_alpha_o(me_alpha)
    );

    bullet bullet_inst
    (
        .clk_run(clk_run),
        .clk_vga(clk_vga),
        .rst(rst),
        .me_x_pos_i(me_x_pos),
        .me_y_pos_i(me_y_pos),
        .req_x_addr_i(req_x_addr),
        .req_y_addr_i(req_y_addr),
        .shoot_mode_i(shoot_mode),
        .crash_enemy_bullet_i(crash_enemy_bullet),
        .vga_rgb_o(bullet_rgb),
        .vga_alpha_o(bullet_alpha)
    );

    enemy_top enemy_top_inst
    (
        .clk_vga(clk_vga),
        .clk_run(clk_run),
        .rst(rst),
        .en_i(disp),
        .rand_i(rand),
        .v_sync_i(v_sync_o),
        .req_x_addr_i(req_x_addr),
        .req_y_addr_i(req_y_addr),
        .crash_enemy_bullet_i(crash_enemy_bullet),
        .crash_me_enemy_i(crash_me_enemy),
        .bomb_i(bomb),
        .vga_alpha_o(enemy_alpha),
        .vga_rgb_o(enemy_rgb),
        .add_score_o(add_score)
    );

    bonus bonus_inst
    (
        .clk_vga(clk_vga),
        .clk_run(clk_run),
        .rst(rst),
        .en_i(disp),
        .rand_i(rand),
        .v_sync_i(v_sync_o),
        .req_x_addr_i(req_x_addr),
        .req_y_addr_i(req_y_addr),
        .crash_me_bonus_i(crash_me_bonus),
        .vga_alpha_o(bonus_alpha),
        .vga_rgb_o(bonus_rgb),
        .bomb_o(bomb),
        .shoot_mode_o(shoot_mode)
    );


    info info_inst
    (
        .clk_vga(clk_vga),
        .rst(rst),
        .req_x_addr_i(req_x_addr),
        .req_y_addr_i(req_y_addr),
        .v_sync_i(v_sync_o),
        .score_i(score),
        .score_digit_i(score_digit),
        .vga_alpha_o(info_alpha)
    );

    score score_inst
    (
        .clk_vga(clk_vga),
        .rst(rst),
        .add_score_i(add_score),
        .score_o(score),
        .score_digit_o(score_digit)
    );
endmodule //top
