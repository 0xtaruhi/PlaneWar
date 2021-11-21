/*
 * Description  : game controlling signal
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-10 22:39:33
 * LastEditTime : 2021-11-21 13:42:50
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\game_ctrl.v
 */
`include "../header/define.v"
 module game_ctrl (
    input  wire                            clk_vga,
    input  wire                            rst,
    
    input  wire                            me_alpha_i,
    input  wire                            bullet_alpha_i,
    input  wire                            enemy_alpha_i,
    input  wire                            bonus_alpha_i,
    input  wire                            disp_i,

    input  wire                            gamestart_i,

    output wire [`GAME_STATUS_BIT_LEN-1:0] game_status_o,

    output wire                            bomb_o,
    output wire                            crash_me_enemy_o,
    output wire                            crash_enemy_bullet_o,
    output wire                            crash_me_bonus_o
);

    localparam STATUS_PAUSE  = `GAME_STATUS_BIT_LEN'b000;
    localparam STATUS_RUN    = `GAME_STATUS_BIT_LEN'b001;
    localparam STATUS_OVER   = `GAME_STATUS_BIT_LEN'b011;
    localparam STATUS_PRERUN = `GAME_STATUS_BIT_LEN'b010;

    reg  [`GAME_STATUS_BIT_LEN-1:0] game_status;
    reg  [`GAME_STATUS_BIT_LEN-1:0] n_game_status;
    wire                            gameover;

    assign crash_enemy_bullet_o = ~rst ? enemy_alpha_i & bullet_alpha_i & disp_i : 0;
    assign crash_me_enemy_o = ~rst ? me_alpha_i & enemy_alpha_i & disp_i : 0;
    // assign crash_me_bonus_o = ~rst ? me_alpha_i & bonus_alpha_i & disp_i : 0;
    assign crash_me_bonus_o = me_alpha_i & bonus_alpha_i;
    assign gameover = crash_enemy_bullet_o;
    assign bomb_o = crash_me_bonus_o;

    always @(posedge clk_vga or posedge rst) begin
        if(rst) begin
            game_status <= STATUS_PRERUN;
        end else begin
            game_status <= n_game_status;
        end
    end

    always @(*) begin
        if(gameover) begin
            n_game_status = STATUS_OVER;
        end else if(gamestart_i) begin
            n_game_status = STATUS_RUN;
        end
    end

endmodule //game_ctrl