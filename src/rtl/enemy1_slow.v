/*
 * Description  : 
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-19 16:05:01
 * LastEditTime : 2021-11-20 12:00:30
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\enemy1_slow.v
 */
`include "../header/define.v"
module enemy1_slow (
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

    /*
        COE file infomation:
        total: 20bits
            ('alpha', enemy1.get_alphainfo())
            ('gray', enemy1.get_grayinfo())
            ('alpha', enemy1_down1.get_alphainfo())
            ('gray', enemy1_down1.get_grayinfo())
            ('alpha', enemy1_down2.get_alphainfo())
            ('gray', enemy1_down2.get_grayinfo())
            ('alpha', enemy1_down3.get_alphainfo())
            ('gray', enemy1_down3.get_grayinfo()))
    */
    // parameters
    localparam STATE_NORMAL = 3'b101;
    localparam STATE_DOWN1 = 3'b110;
    localparam STATE_DOWN2 = 3'b010;
    localparam STATE_DOWN3 = 3'b011;
    localparam STATE_UNVISUAL = 3'b111;

    //wires and registers
    wire [               `ENEMY1_NUM-1:0] disappear;
    wire [`ENEMY1_BRAM_DEPTH_BIT_LEN-1:0] bram_addr;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_normal;
    wire                                  bram_alpha_normal;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_down1;
    wire                                  bram_alpha_down1;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_down2;
    wire                                  bram_alpha_down2;
    wire                                  bram_alpha_down3;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_down3;
    wire [        `ENEMY1_BRAM_WIDTH-1:0] bram_info;
    wire                                  enemy_vali;
    wire [       `ENEMY1_NUM_BIT_LEN-1:0] curr_enemy_idx;
    // state
    reg  [   `ENEMY1_STATE_REG_WIDTH-1:0] state_unit       [`ENEMY1_NUM-1:0];
    reg  [   `ENEMY1_STATE_REG_WIDTH-1:0] n_state_unit     [`ENEMY1_NUM-1:0];
    // counter
    reg  [`ENEMY1_CNT_MAX_TRIGGER_BIT_LEN-1:0] cnt_trigger;
    reg  [    `ENEMY_CNT_MAX_DOWN_BIT_LEN-1:0] cnt_down;
    // state change signal
    reg                                   state_change;
    //trigger signal
    wire                                  trigger;
    wire [`ENEMY1_NUM_BIT_LEN-1:0]        trigger_idx;
    reg                                   vga_alpha;
    reg  [          `COLOR_RGB_DEPTH-1:0] vga_rgb;

    enemy_base
    #(
        .MAX_ENEMY_NUM(`ENEMY1_NUM),
        .MAX_ENEMY_NUM_BIT_LEN(`ENEMY1_NUM_BIT_LEN),
        .SPEED(`ENEMY1_SPEED_LOW),
        // .TRIGGER_FREQ(`ENEMY1_TRIGGER_FREQ),
        .ENEMY_CNT_MAX_TRIGGER(`ENEMY1_CNT_MAX_TRIGGER),
        .ENEMY_X_SIZE(`ENEMY1_X_SIZE),
        .ENEMY_Y_SIZE(`ENEMY1_Y_SIZE),
        .RAND_POS_BIT_LEN(`OBJ_X_POS_BIT_LEN-1),
        .RAND_OFFSET(`ENEMY1_SLOW_RAND_OFFSET),
        .BRAM_WIDTH(`ENEMY1_BRAM_WIDTH),
        .BRAM_DEPTH(`ENEMY1_BRAM_DEPTH),
        .BRAM_DEPTH_BIT_LEN(`ENEMY1_BRAM_DEPTH_BIT_LEN)
    ) enemy1_slow
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

    bram_enemy1 bram_enemy1_slow
    (
        .clka(clk_vga),
        .ena(1'b1),
        .addra(bram_addr),
        .douta(bram_info)
    );

    assign {bram_alpha_normal, bram_gray_normal,
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
                STATE_NORMAL:begin
                    vga_alpha = bram_alpha_normal;
                    vga_rgb   = {3{bram_gray_normal}};
                end
                STATE_DOWN1:begin
                    vga_alpha = bram_alpha_down1;
                    vga_rgb   = {3{bram_gray_down1}};
                end
                STATE_DOWN2:begin
                    vga_alpha = bram_alpha_down2;
                    vga_rgb   = {3{bram_gray_down2}};
                end
                STATE_DOWN3:begin
                    vga_alpha = bram_alpha_down3;
                    vga_rgb   = {3{bram_gray_down3}};
                end
                STATE_UNVISUAL:begin
                    vga_alpha = 0;
                    vga_rgb   = 0;
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
        for(i=0;i<`ENEMY1_NUM;i=i+1)begin: loop
            always @(posedge clk_vga or posedge rst) begin
                if(rst)begin
                    state_unit[i] <= STATE_NORMAL;
                end else begin
                    state_unit[i] <= n_state_unit[i];
                end
            end

            always @(*)begin
                case(state_unit[i])
                    STATE_NORMAL:
                        n_state_unit[i] = ((crash_enemy_bullet_i || crash_me_enemy_i) && i == curr_enemy_idx) ? STATE_DOWN1 : STATE_NORMAL;
                    STATE_DOWN1:
                        n_state_unit[i] = state_change ? STATE_DOWN2 : STATE_DOWN1;
                    STATE_DOWN2:
                        n_state_unit[i] = state_change ? STATE_DOWN3 : STATE_DOWN2;
                    STATE_DOWN3:
                        n_state_unit[i] = state_change ? STATE_UNVISUAL : STATE_DOWN3;
                    STATE_UNVISUAL:
                        n_state_unit[i] = (trigger && trigger_idx == i) ? STATE_NORMAL : STATE_UNVISUAL;
                    default:
                        n_state_unit[i] = STATE_UNVISUAL;
                endcase
            end
    
            assign disappear[i] = state_unit[i] == STATE_UNVISUAL;
        end
    endgenerate

endmodule //enemy1_slow