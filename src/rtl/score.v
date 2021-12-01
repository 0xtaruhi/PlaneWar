/*
 * Description  : score
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-23 15:58:36
 * LastEditTime : 2021-11-24 17:26:58
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\score.v
 */

`include "../header/define.v"
 module score (
     input  wire clk_vga,
     input  wire rst,
     input  wire [ `ADD_SCORE_BIT_WIDTH-1:0] add_score_i,
    //  input  wire                             me_normal_i,
     input  wire [ `GAME_STATUS_BIT_LEN-1:0] game_status_i,
     
     output reg  [     `SCORE_WIDTH_DEC-1:0] score_o,
     output reg  [                      1:0] score_digit_o
 );

    reg [`ADD_SCORE_BIT_WIDTH-1:0] add_score_buff;

    always @(posedge clk_vga or posedge rst) begin
        if(rst)begin
            add_score_buff <= 0;
            score_o <= 0;
        // end else if(~me_normal_i) begin
        //     add_score_buff <= 0;
        //     score_o <= score_o;
        // end else if(game_status_i != `GAME_STATUS_RUN) begin
        //     score_o <= score_o;
        //     add_score_buff <= 0;
        end else begin
            if(add_score_buff) begin
                add_score_buff <= add_score_buff + add_score_i - 1;
                if(score_o[3:0] == 9) begin
                    if(score_o[7:4] == 9) begin
                        if(score_o[11:8] == 9) begin
                            score_o <= score_o;
                        end else begin
                            score_o[11:8] <= score_o[11:8] + 1;
                            score_o[7:4]  <= 0;
                        end
                    end else begin
                        score_o[7:4] <= score_o[7:4] + 1;
                        score_o[3:0] <= 0;
                    end
                end else begin
                    score_o[3:0] <= score_o[3:0] + 1;
                end
            end else begin
                add_score_buff <= add_score_i;
            end
        end
    end
 
    always @(*) begin
        if(score_o[11:8]) begin
            score_digit_o = 3;
        end else if(score_o[7:4]) begin
            score_digit_o = 2;
        end else if(score_o[3:0]) begin
            score_digit_o = 1;
        end else begin
            score_digit_o = 0;
        end
    end

 endmodule //score