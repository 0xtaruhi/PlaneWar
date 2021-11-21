/*
 * Description  : bomb, double shoot
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-21 11:17:32
 * LastEditTime : 2021-11-21 16:39:27
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
    output wire [`COLOR_RGB_DEPTH-1:0] vga_rgb_o,
    output wire                        bomb_o,
    output wire                        shoot_mode_o
);

    wire                                         vga_alpha_bomb;
    wire [                 `COLOR_RGB_DEPTH-1:0] vga_rgb_bomb;
    wire                                         vga_alpha_bullet_supply;
    wire [                 `COLOR_RGB_DEPTH-1:0] vga_rgb_bullet_supply;
    reg  [`BULLET_SUP_CNT_MAX_BONUS_BIT_LEN-1:0] bullet_sup_cnt;
    reg                                          bullet_sup_cnt_vali;
    reg                                          shoot_mode;
    wire                                         crash_bullet_supply;
    reg                                          supply;
    reg                                          supply_timeout;

    bomb_supply bomb_supply_dut
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

    bullet_supply bullet_supply_dut
    (
        .clk_run(clk_run),
        .clk_vga(clk_vga),
        .rst(rst),
        .en_i(en_i),
        .rand_i(rand_i),
        .v_sync_i(v_sync_i),
        .req_x_addr_i(req_x_addr_i),
        .req_y_addr_i(req_y_addr_i),
        .crash_me_bonus_i(crash_me_bonus_i & vga_alpha_bullet_supply),
        .vga_alpha_o(vga_alpha_bullet_supply),
        .vga_rgb_o(vga_rgb_bullet_supply)
    );

    assign vga_alpha_o = vga_alpha_bomb | vga_alpha_bullet_supply;
    assign vga_rgb_o = vga_alpha_bomb ? vga_rgb_bomb :
                       vga_alpha_bullet_supply ? vga_rgb_bullet_supply : 0;
    assign bomb_o = vga_alpha_bomb & crash_me_bonus_i;
    assign crash_bullet_supply = vga_alpha_bullet_supply & crash_me_bonus_i;

    always @(posedge clk_run or posedge rst) begin
        if(rst) begin
            bullet_sup_cnt <= 0;
            supply_timeout <= 0;
        end else begin
            if(bullet_sup_cnt_vali) begin
                if(bullet_sup_cnt == `BULLET_SUP_CNT_MAX_BONUS - 1) begin
                    bullet_sup_cnt <= 0;
                    supply_timeout <= 1;
                end else begin
                    bullet_sup_cnt <= bullet_sup_cnt + 1;
                    supply_timeout <= 0;
                end
            end else begin
                bullet_sup_cnt <= 0;
                supply_timeout <= 0;
            end
        end
    end

    always @(posedge clk_vga or posedge rst) begin
        if(rst) begin
            bullet_sup_cnt_vali <= 0;
            shoot_mode <= `BULLET_MODE_SINGLE;
        end else begin
            if(crash_bullet_supply) begin
                bullet_sup_cnt_vali <= 1;
                shoot_mode <= `BULLET_MODE_DOUBLE;
            end else if(supply_timeout) begin
                bullet_sup_cnt_vali <= 0;
                shoot_mode <= `BULLET_MODE_SINGLE;
            end else begin
                bullet_sup_cnt_vali <= bullet_sup_cnt_vali;
                shoot_mode <= shoot_mode;
            end
        end
    end

    assign shoot_mode_o = shoot_mode;

endmodule //bonus