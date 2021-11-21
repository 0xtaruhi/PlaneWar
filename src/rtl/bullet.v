/*
 * Description  : bullet
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-03 23:07:17
 * LastEditTime : 2021-11-21 15:47:08
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\bullet.v
 */
`include "../header/define.v"
module bullet (
        input wire                           clk_run,               // by default, clk(run) is 250MHz
        input wire                           clk_vga,
        input wire                           rst,

        input  wire [`OBJ_X_POS_BIT_LEN-1:0] me_x_pos_i,
        input  wire [`OBJ_Y_POS_BIT_LEN-1:0] me_y_pos_i,
        input  wire [       `H_DISP_LEN-1:0] req_x_addr_i,
        input  wire [       `V_DISP_LEN-1:0] req_y_addr_i,
        input  wire                          shoot_mode_i,            // 0 when single and 1 when d
        input  wire                          crash_enemy_bullet_i,

        output wire [  `COLOR_RGB_DEPTH-1:0] vga_rgb_o,
        output wire                          vga_alpha_o
    );

    parameter SPEED = `BULLET_SPEED;                    // move 300 pixels in 0.20sec in default
    localparam UP_BOUND = SPEED;

    // req_x/y_addr_i should be delayed 2 cycles because of the bram
    wire [           `H_DISP_LEN-1:0] req_x_addr_delayed;
    wire [           `V_DISP_LEN-1:0] req_y_addr_delayed;
    // bullet properties
    reg  [           `H_DISP_LEN-1:0] bullet_x_pos [`BULLET_NUM-1:0];
    reg  [           `V_DISP_LEN-1:0] bullet_y_pos [`BULLET_NUM-1:0];
    reg  [                       2:0] visible      [`BULLET_NUM-1:0];       // visible[idx][0]->center, visible[idx][1]->left, visible[idx][2]->right
    reg  [`CNT_MAX_SHOOT_BIT_LEN-1:0] cnt_shoot;
    reg  [   `BULLET_NUM_BIT_LEN-1:0] shoot_bullet_idx;
    reg                               shoot;
    wire [                       6:0] bullet_x_offset;
    wire [                       6:0] bullet_y_offset;
    wire [                       2:0] bullet_vali_unit [`BULLET_NUM-1:0];
    wor                               left_bullet_vali;                     // current require pixel is occupied by a left bullet
    wor                               right_bullet_vali;
    wor                               center_bullet_vali;
    wire                              vga_alpha;
    wire [      `COLOR_RGB_DEPTH-1:0] vga_rgb;
    wire                              y_pos_in_req_area [`BULLET_NUM-1:0];
    wor  [   `BULLET_NUM_BIT_LEN-1:0] curr_bullet_idx;

    dff_delay #(.DATA_WIDTH(`H_DISP_LEN)) dff_delay_x
    (
        .clk(clk_vga),
        .rst(rst),
        .en_i(1'b1),
        .data_i(req_x_addr_i),
        .data_o(req_x_addr_delayed)
    );
    dff_delay #(.DATA_WIDTH(`V_DISP_LEN)) dff_delay_y
    (
        .clk(clk_vga),
        .rst(rst),
        .en_i(1'b1),
        .data_i(req_y_addr_i),
        .data_o(req_y_addr_delayed)
    );

    assign bullet_x_offset = `BULLET_SINGLE_X_OFFSET;
    assign bullet_y_offset = (shoot_mode_i == `BULLET_MODE_SINGLE) ?
           `BULLET_SINGLE_Y_OFFSET :
           `BULLET_DOUBLE_Y_OFFSET;

    // control the moving of bullets
    genvar i;
    generate
        for(i=0;i<`BULLET_NUM;i=i+1) begin : BULLET_LOOP
            always @(posedge clk_run or posedge rst) begin
                if(rst) begin
                    bullet_x_pos[i] <= 0;
                    bullet_y_pos[i] <= 0;
                end
                else begin
                    if(shoot &&(i == shoot_bullet_idx)) begin
                        bullet_x_pos[i] <= me_x_pos_i + bullet_x_offset;
                        bullet_y_pos[i] <= me_y_pos_i + bullet_y_offset;
                    end
                    else begin
                        if(bullet_y_pos[i] >= UP_BOUND) begin
                            bullet_y_pos[i] <= bullet_y_pos[i] - SPEED;
                        end
                        else begin // out of screen
                            bullet_y_pos[i] <= bullet_y_pos[i];
                        end
                    end
                end
            end

            //visible
            always@(posedge clk_vga or posedge rst)begin
                if(rst) begin
                    visible[i] <= 0;
                end else begin
                    if(shoot &&(shoot_bullet_idx == i)) begin
                        visible[i] <= (shoot_mode_i == `BULLET_MODE_SINGLE) ? 3'b001 : 3'b110;
                    end else if(bullet_y_pos[i] <= UP_BOUND) begin
                        visible[i] <= 0;
                    end else if(crash_enemy_bullet_i && |bullet_vali_unit[i]) begin
                        visible[i][`BULLET_LEFT] <= bullet_vali_unit[i][`BULLET_LEFT] ? 0 : visible[i][`BULLET_LEFT];
                        visible[i][`BULLET_RIGHT] <= bullet_vali_unit[i][`BULLET_RIGHT] ? 0 : visible[i][`BULLET_RIGHT];
                        visible[i][`BULLET_CENTER] <= bullet_vali_unit[i][`BULLET_CENTER] ? 0 : visible[i][`BULLET_CENTER];
                    end else begin
                        visible[i] <= visible[i];
                    end
                end
            end
        end
    endgenerate

    // control shoot signal and shooting bullet index
    always @(posedge clk_run or posedge rst) begin
        if(rst) begin
            cnt_shoot <= 0;
            shoot_bullet_idx <= 0;
            shoot <= 0;
        end
        else begin
            if(cnt_shoot == `CNT_MAX_SHOOT-1) begin
                cnt_shoot <= 0;
                shoot <= 1;
                if(shoot_bullet_idx >= `BULLET_NUM-1) begin
                    shoot_bullet_idx <= 0;
                end
                else begin
                    shoot_bullet_idx <= shoot_bullet_idx + 1;
                end
            end
            else begin
                cnt_shoot <= cnt_shoot + 1;
                shoot <= 0;
            end
        end
    end

    genvar j;
    generate
        for(j=0;j<`BULLET_NUM;j=j+1) begin : VGA_ALPHA_LOOP
            assign y_pos_in_req_area[j] = (req_y_addr_delayed >= bullet_y_pos[j])
                                && (req_y_addr_delayed < bullet_y_pos[j] + `BULLET_HEIGHT);
            assign bullet_vali_unit[j][`BULLET_CENTER] = visible[j][`BULLET_CENTER]
                                && (req_x_addr_delayed >= bullet_x_pos[j])
                                && (req_x_addr_delayed < bullet_x_pos[j] + `BULLET_WIDTH)
                                && y_pos_in_req_area[j];
            assign bullet_vali_unit[j][`BULLET_LEFT] = visible[j][`BULLET_LEFT]
                                && (req_x_addr_delayed >= bullet_x_pos[j] + `BULLET_LEFT2CENTER)
                                && (req_x_addr_delayed < bullet_x_pos[j] + `BULLET_LEFT2CENTER + `BULLET_WIDTH)
                                && y_pos_in_req_area[j];
            assign bullet_vali_unit[j][`BULLET_RIGHT] = visible[j][`BULLET_RIGHT]
                                && (req_x_addr_delayed >= bullet_x_pos[j] + `BULLET_RIGHT2CENTER)
                                && (req_x_addr_delayed < bullet_x_pos[j] + `BULLET_RIGHT2CENTER + `BULLET_WIDTH)
                                && y_pos_in_req_area[j];
            assign left_bullet_vali = bullet_vali_unit[j][`BULLET_LEFT];
            assign right_bullet_vali = bullet_vali_unit[j][`BULLET_RIGHT];
            assign center_bullet_vali = bullet_vali_unit[j][`BULLET_CENTER];
        end
    endgenerate

    assign vga_alpha = center_bullet_vali | left_bullet_vali | right_bullet_vali;
    assign vga_rgb = center_bullet_vali ? `BULLET_SINGLE_COLOR : `BULLET_DOUBLE_COLOR;
    assign vga_rgb_o = vga_rgb;
    assign vga_alpha_o = vga_alpha;

endmodule //bullet
