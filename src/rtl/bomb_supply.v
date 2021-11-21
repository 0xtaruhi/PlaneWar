/*
 * Description  : bomb supply(as a special enemy)
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-21 10:43:58
 * LastEditTime : 2021-11-21 15:12:49
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\bomb_supply.v
 */
`include "../header/define.v"
module bomb_supply (
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

    // FSM state
    localparam STATE_VALI = 1'b1;
    localparam STATE_INVALI = 1'b0;

    //wires and registers
    wire [               `BOMB_NUM-1:0] disappear;
    wire [`BOMB_BRAM_DEPTH_BIT_LEN-1:0] bram_addr;
    wire [        `COLOR_RGB_DEPTH-1:0] bram_color;
    wire                                bram_alpha;
    wire [        `BOMB_BRAM_WIDTH-1:0] bram_info;
    wire                                enemy_vali;
    wire [       `BOMB_NUM_BIT_LEN-1:0] curr_enemy_idx;
    // counter
    reg  [`BOMB_CNT_MAX_TRIGGER_BIT_LEN-1:0] cnt_trigger;
    reg  [  `ENEMY_CNT_MAX_DOWN_BIT_LEN-1:0] cnt_down;
    //trigger signal
    wire                                trigger;
    wire [       `BOMB_NUM_BIT_LEN-1:0] trigger_idx;
    reg                                 vga_alpha;
    reg  [        `COLOR_RGB_DEPTH-1:0] vga_rgb;
    // state
    reg                                 state_unit [`BOMB_NUM-1:0];
    reg                                 n_state_unit [`BOMB_NUM-1:0];

    enemy_base
    #(
        .MAX_ENEMY_NUM(`BOMB_NUM),
        .MAX_ENEMY_NUM_BIT_LEN(`BOMB_NUM_BIT_LEN),
        .SPEED(`BOMB_SPEED),
        .ENEMY_CNT_MAX_TRIGGER(`BOMB_CNT_MAX_TRIGGER),
        .ENEMY_X_SIZE(`BOMB_X_SIZE),
        .ENEMY_Y_SIZE(`BOMB_Y_SIZE),
        .RAND_POS_BIT_LEN(`OBJ_X_POS_BIT_LEN-1),
        .RAND_OFFSET(`BOMB_RAND_OFFSET),
        .BRAM_WIDTH(`BOMB_BRAM_WIDTH),
        .BRAM_DEPTH(`BOMB_BRAM_DEPTH),
        .BRAM_DEPTH_BIT_LEN(`BOMB_BRAM_DEPTH_BIT_LEN)
    ) bomb
    (
        .clk_vga(clk_vga),
        .clk_run(clk_run),
        .rst(rst),
        .en_i(en_i),
        .v_sync_i(v_sync_i),
        .req_x_addr_i(req_x_addr_i),
        .req_y_addr_i(req_y_addr_i),
        .disappear_i(disappear),
        .rand_pos_i(rand_i),
        .bram_addr_o(bram_addr),
        .enemy_vali_o(enemy_vali),
        .curr_enemy_idx_o(curr_enemy_idx),
        .trigger_o(trigger),
        .trigger_idx_o(trigger_idx)
    );

    bram_bomb bram_bomb_dut
    (
        .clka(clk_vga),
        .ena(1'b1),
        .addra(bram_addr),
        .douta(bram_info)
    );

    assign {bram_alpha, bram_color} = bram_info;

    genvar i;
    generate
        for(i=0;i<`BOMB_NUM;i=i+1) begin:BOMB_LOOP

            always @(posedge clk_vga or posedge rst) begin
                if(rst) begin
                    state_unit[i] <= STATE_INVALI;
                end else begin
                    state_unit[i] <= n_state_unit[i];
                end
            end

            assign disappear[i] = state_unit[i] == STATE_INVALI;

            always @(*) begin
                case(state_unit[i])
                    STATE_INVALI:
                        n_state_unit[i] = (trigger && trigger_idx == i) ?
                                        STATE_VALI : STATE_INVALI;
                    STATE_VALI:
                        n_state_unit[i] = (crash_me_bonus_i && curr_enemy_idx == i)?
                                        STATE_INVALI : STATE_VALI;
                    default:
                        n_state_unit[i] = STATE_INVALI;
                endcase
            end
        end
    endgenerate

    assign vga_alpha_o = enemy_vali ? bram_alpha : 0;
    // assign vga_alpha_o = 1;
    assign vga_rgb_o   = enemy_vali ? bram_color : 0;

endmodule //bomb_supply