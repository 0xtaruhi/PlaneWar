/*
 * Description  : game controlling signal
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-10 22:39:33
 * LastEditTime : 2021-11-11 12:29:34
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\game_ctrl.v
 */
module game_ctrl (
    input  wire clk,
    input  wire rst,
    input  wire me_alpha_i,
    input  wire bullet_alpha_i,
    input  wire enemy1_alpha_i,

    output wire bomb_o,
    output wire crash_me_enemy_o,
    output wire crash_enemy_bullet_o
);

    assign crash_enemy_bullet_o = ~rst ? enemy1_alpha_i & bullet_alpha_i : 0;
    assign crash_me_enemy_o = ~rst ? me_alpha_i & enemy1_alpha_i : 0;

endmodule //game_ctrl