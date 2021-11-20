/*
 * Description  : 
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-20 10:23:02
 * LastEditTime : 2021-11-20 12:31:09
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\enemy3.v
 */
`include "../header/define.v"
 module enemy3 (
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

    output wire                        vga_alpha_o,
    output wire [`COLOR_RGB_DEPTH-1:0] vga_rgb_o
);

    // FSM state
    localparam STATE_NORMAL   = 3'b001;
    localparam STATE_HIT      = 3'b010;
    localparam STATE_DOWN1    = 3'b011;
    localparam STATE_DOWN2    = 3'b100;
    localparam STATE_DOWN3    = 3'b101;
    localparam STATE_UNVISUAL = 3'b110;

    //wires and registers
    wire [               `ENEMY3_NUM-1:0] disappear;
    wire [`ENEMY3_BRAM_DEPTH_BIT_LEN-1:0] bram_addr;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_normal;
    wire                                  bram_alpha_normal;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_hit;
    wire                                  bram_alpha_hit;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_down1;
    wire                                  bram_alpha_down1;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_down2;
    wire                                  bram_alpha_down2;
    wire                                  bram_alpha_down3;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_down3;
    wire [        `ENEMY3_BRAM_WIDTH-1:0] bram_info;
    wire                                  enemy_vali;
    wire [       `ENEMY3_NUM_BIT_LEN-1:0] curr_enemy_idx;
    // state
    reg  [   `ENEMY3_STATE_REG_WIDTH-1:0] state_unit       [`ENEMY3_NUM-1:0];
    reg  [   `ENEMY3_STATE_REG_WIDTH-1:0] n_state_unit     [`ENEMY3_NUM-1:0];
    reg  [      `ENEMY3_LIFE_BIT_LEN-1:0] life [`ENEMY3_NUM-1:0];
    // counter
    reg  [`ENEMY3_CNT_MAX_TRIGGER_BIT_LEN-1:0] cnt_trigger;
    reg  [    `ENEMY_CNT_MAX_DOWN_BIT_LEN-1:0] cnt_down;
    // state change signal
    reg                                   state_change;
    //trigger signal
    wire                                  trigger;
    wire [       `ENEMY3_NUM_BIT_LEN-1:0] trigger_idx;
    reg                                   vga_alpha;
    reg  [          `COLOR_RGB_DEPTH-1:0] vga_rgb;

    enemy_base
    #(
        .MAX_ENEMY_NUM(`ENEMY3_NUM),
        .MAX_ENEMY_NUM_BIT_LEN(`ENEMY3_NUM_BIT_LEN),
        .SPEED(`ENEMY3_SPEED),
        // .TRIGGER_FREQ(`ENEMY3_TRIGGER_FREQ),
        .ENEMY_CNT_MAX_TRIGGER(`ENEMY3_CNT_MAX_TRIGGER),
        .ENEMY_X_SIZE(`ENEMY3_X_SIZE),
        .ENEMY_Y_SIZE(`ENEMY3_Y_SIZE),
        .RAND_POS_BIT_LEN(`OBJ_X_POS_BIT_LEN-1),
        .RAND_OFFSET(`ENEMY3_RAND_OFFSET),
        .BRAM_WIDTH(`ENEMY3_BRAM_WIDTH),
        .BRAM_DEPTH(`ENEMY3_BRAM_DEPTH),
        .BRAM_DEPTH_BIT_LEN(`ENEMY3_BRAM_DEPTH_BIT_LEN)
    ) enemy3
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

    bram_enemy3 bram_enemy3_dut
    (
        .clka(clk_vga),
        .ena(1'b1),
        .addra(bram_addr),
        .douta(bram_info)
    );

    assign {bram_alpha_normal, bram_gray_normal,
            bram_alpha_hit, bram_gray_hit,
            bram_alpha_down1, bram_gray_down1,
            bram_alpha_down2, bram_gray_down2,
            bram_alpha_down3, bram_gray_down3} = bram_info;

    always @(posedge clk_vga or posedge rst)begin
        if(rst) begin
            cnt_down <= 0;
        end else begin
            if(cnt_down == `ENEMY_CNT_MAX_DOWN - 1)begin
                state_change <= 1;
                cnt_down <= 0;
            end else begin
                state_change <= 0;
                cnt_down <= cnt_down + 1;
            end
        end
    end

    always @(*) begin
        if(enemy_vali) begin
            case(state_unit[curr_enemy_idx])
                STATE_NORMAL: begin
                    vga_alpha = bram_alpha_normal;
                    vga_rgb   = {3{bram_gray_normal}};
                end
                STATE_HIT: begin
                    vga_alpha = bram_alpha_hit;
                    vga_rgb   = {3{bram_gray_hit}};
                end
                STATE_DOWN1: begin
                    vga_alpha = bram_alpha_down1;
                    vga_rgb   = {3{bram_gray_down1}};
                end
                STATE_DOWN2: begin
                    vga_alpha = bram_alpha_down2;
                    vga_rgb   = {3{bram_gray_down2}};
                end
                STATE_DOWN3: begin
                    vga_alpha = bram_alpha_down3;
                    vga_rgb   = {3{bram_gray_down3}};
                end
                default: begin
                    vga_alpha = 0;
                    vga_rgb   = 0;
                end
            endcase
        end else begin
            vga_alpha = 0;
            vga_rgb   = 0;
        end
    end

    assign vga_alpha_o = vga_alpha;
    assign vga_rgb_o   = vga_rgb;

    genvar i;
    generate
        for(i=0;i<`ENEMY3_NUM;i=i+1)begin: enemy3_loop
            always @(posedge clk_vga or posedge rst)begin
                if(rst) begin
                    state_unit[i] <= STATE_NORMAL;
                end else begin
                    state_unit[i] <= n_state_unit[i];
                end
            end

            always @(posedge clk_vga or posedge rst) begin
                if(rst) begin
                    life[i] <= `ENEMY3_LIFE;
                end else begin
                    if(state_unit[i] == STATE_UNVISUAL) begin
                        life[i] <= `ENEMY3_LIFE;
                    end else if(curr_enemy_idx == i) begin
                        if(crash_me_enemy_i) begin
                            life[i] <= 0;
                        end else if(crash_enemy_bullet_i) begin
                            life[i] <= life[i] - 1;
                        end else begin
                            life[i] <= life[i];
                        end
                    end
                end
            end

            always @(*) begin
                case(state_unit[i])
                    STATE_NORMAL: 
                        n_state_unit[i] = ((crash_enemy_bullet_i || crash_me_enemy_i) && curr_enemy_idx == i) ?
                                            STATE_HIT : STATE_NORMAL;
                    STATE_HIT: 
                        n_state_unit[i] = state_change ? life[i] == 0 ? STATE_DOWN1 : STATE_NORMAL : STATE_HIT;
                    STATE_DOWN1: 
                        n_state_unit[i] = state_change ? STATE_DOWN2 : STATE_DOWN1;
                    STATE_DOWN2: 
                        n_state_unit[i] = state_change ? STATE_DOWN3 : STATE_DOWN2;
                    STATE_DOWN3:
                        n_state_unit[i] = state_change ? STATE_UNVISUAL : STATE_DOWN3;
                    STATE_UNVISUAL:
                        n_state_unit[i] = (trigger && trigger_idx == i) ? STATE_NORMAL :
                                            STATE_UNVISUAL;
                    default:
                        n_state_unit[i] = STATE_UNVISUAL;
                endcase
            end

            assign disappear[i] = state_unit[i] == STATE_UNVISUAL;
        end
    endgenerate

endmodule //enemy3