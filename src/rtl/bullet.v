/*
 * Description  : bullet
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-03 23:07:17
 * LastEditTime : 2021-11-07 17:52:11
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\bullet.v
 */
`include "../header/define.v"
module bullet (
        input wire                           clk,               // by default, clk(run) is 250MHz
        input wire                           rst,

        input  wire [`OBJ_X_POS_BIT_LEN-1:0] me_x_pos_i,
        input  wire [`OBJ_Y_POS_BIT_LEN-1:0] me_y_pos_i,
        input  wire [       `H_DISP_LEN-1:0] req_x_addr_i,
        input  wire [       `V_DISP_LEN-1:0] req_y_addr_i,
        input  wire                          mode_i,            // 0 when single and 1 when double

        output wire [  `COLOR_RGB_DEPTH-1:0] vga_rgb_o,
        output wire                          vga_alpha_o
    );

    parameter SPEED = 5;                    // move 300 pixels in 0.20sec in default
    localparam UP_BOUND = SPEED;

    reg  [           `H_DISP_LEN-1:0] bullet_x_pos [`BULLET_NUM-1:0];
    reg  [           `V_DISP_LEN-1:0] bullet_y_pos [`BULLET_NUM-1:0];
    reg  [           `BULLET_NUM-1:0] visible;
    reg  [`CNT_MAX_SHOOT_BIT_LEN-1:0] cnt_shoot;
    reg  [   `BULLET_NUM_BIT_LEN-1:0] shoot_bullet_idx;
    reg                               shoot;
    wire [                       6:0] bullet_x_offset;
    wire [                       6:0] bullet_y_offset;
    wor                               vga_alpha;

    assign bullet_x_offset = (mode_i == `BULLET_MODE_SINGLE) ?
           `BULLET_SINGLE_X_OFFSET :
           `BULLET_DOUBLE_X_OFFSET;
    assign bullet_y_offset = (mode_i == `BULLET_MODE_SINGLE) ?
           `BULLET_SINGLE_Y_OFFSET :
           `BULLET_DOUBLE_Y_OFFSET;

    // control the moving of bullets
    genvar i;
    generate
        for(i=0;i<`BULLET_NUM;i=i+1) begin : BULLET_LOOP
            always @(posedge clk or posedge rst) begin
                if(rst) begin
                    bullet_x_pos[i] <= 0;
                    bullet_y_pos[i] <= 0;
                    visible[i] <= 0;
                end
                else begin
                    if(shoot &&(i == shoot_bullet_idx)) begin
                        visible[i] <= 1;
                        bullet_x_pos[i] <= me_x_pos_i + bullet_x_offset;
                        bullet_y_pos[i] <= me_y_pos_i + bullet_y_offset;
                    end
                    else begin
                        bullet_x_pos[i] <= bullet_x_pos[i];
                        if(bullet_y_pos[i] >= UP_BOUND) begin
                            bullet_y_pos[i] <= bullet_y_pos[i] - SPEED;
                        end
                        else begin // out of screen
                            bullet_y_pos[i] <= bullet_y_pos[i];
                            visible[i] <= 0;
                        end
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk or posedge rst) begin
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

    assign vga_alpha_o = vga_alpha;
    genvar j;
    generate
        for(j=0;j<`BULLET_NUM;j=j+1) begin : VGA_ALPHA_LOOP
            assign vga_alpha = visible[j]
                            && (req_x_addr_i >= bullet_x_pos[j]) 
                            && (req_x_addr_i < bullet_x_pos[j] + `BULLET_WIDTH)
                            && (req_y_addr_i >= bullet_y_pos[j]) 
                            && (req_y_addr_i < bullet_y_pos[j] + `BULLET_HEIGHT);
        end
    endgenerate

    assign vga_rgb_o = `BULLET_SINGLE_COLOR;


endmodule //bullet
