/*
 * Description  : My Craft
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-02 14:37:42
 * LastEditTime : 2021-11-02 20:46:48
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\me.v
 */
`include "../header/define.v"
module me (
        input  wire                          clk_run,
        input  wire                          clk_vga,
        input  wire                          rst,

        input  wire [`H_DISP_LEN-1:0]        req_x_addr_i,
        input  wire [`V_DISP_LEN-1:0]        req_y_addr_i,
        input  wire                          move_en_i,     //移动使能
        input  wire [1:0]                    direct_i,      //移动的方向

        output reg                           moving_o,      //正在移动
        output reg  [`OBJ_X_POS_BIT_LEN-1:0] x_pos_o,
        output reg  [`OBJ_Y_POS_BIT_LEN-1:0] y_pos_o
    );

    localparam SPEED = 2;
    localparam DOWN_BOUND = `V_DISP - `ME_Y_SIZE - SPEED;
    localparam RIGHT_BOUND = `H_DISP - `ME_X_SIZE - SPEED;
    localparam UP_BOUND = SPEED;
    localparam LEFT_BOUND = SPEED;

    bram_me1 bram_me1_dut
    (
        .clka(clk_vga),
        .ena(),
        .addra(),
        .douta()
    );

    always @(posedge clk_run or posedge rst) begin
        if(rst) begin
            x_pos_o <= `ME_DEFAULT_X_POS;
            y_pos_o <= `ME_DEFAULT_Y_POS;
            moving_o <= 0;
        end
        else begin
            if(move_en_i) begin
                case(direct_i)
                    `UP: begin
                        if(y_pos_o > UP_BOUND) begin
                            y_pos_o <= y_pos_o - 1;
                            moving_o <= 1;
                        end else begin
                            y_pos_o <= y_pos_o;
                            moving_o <= 0;
                        end
                    end
                    `DOWN: begin
                        if(y_pos_o < DOWN_BOUND) begin
                            y_pos_o <= y_pos_o + 1;
                            moving_o <= 1;
                        end else begin
                            y_pos_o <= y_pos_o;
                            moving_o <= 0;
                        end
                    end
                    `LEFT: begin
                        if(x_pos_o > LEFT_BOUND) begin
                            x_pos_o <= x_pos_o - 1;
                            moving_o <= 1;
                        end else begin
                            x_pos_o <= x_pos_o;
                            moving_o <= 0;
                        end
                    end
                    `RIGHT: begin
                        if(y_pos_o < RIGHT_BOUND) begin
                            y_pos_o <= y_pos_o + 1;
                            moving_o <= 1;
                        end else begin
                            y_pos_o <= y_pos_o;
                            moving_o <= 0;
                        end
                    end
                endcase
            end
        end
    end

endmodule //me
