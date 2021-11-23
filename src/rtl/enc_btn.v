/*
 * Description  : Encoder of buttons on board
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-03 11:45:47
 * LastEditTime : 2021-11-23 14:59:08
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\enc_btn.v
 */

 `include "../header/define.v"
 module enc_btn (
     input  wire       clk,
     
     input  wire       btn_l_pin_i,
     input  wire       btn_r_pin_i,
     input  wire       btn_u_pin_i,
     input  wire       btn_d_pin_i,
     input  wire       btn_c_pin_i,

     output reg        move_en_o,
     output reg [1:0]  direct_o,
     output reg        rst
 );

    reg [`RST_BTN_TIME_MAX_CNT_BIT_LEN-1:0] rst_btn_time_cnt;

    always @( *) begin
        case({btn_l_pin_i, btn_r_pin_i, btn_u_pin_i, btn_d_pin_i})
            4'b0001: begin
                move_en_o = 1'b1;
                direct_o = `DOWN;
            end
            4'b0010: begin
                move_en_o = 1'b1;
                direct_o = `UP;
            end
            4'b0100: begin
                move_en_o = 1'b1;
                direct_o = `RIGHT;
            end
            4'b1000: begin
                move_en_o = 1'b1;
                direct_o = `LEFT;
            end
            default: begin
                move_en_o = 1'b0;
                direct_o = `DOWN;
            end
        endcase
    end

    always @(posedge clk) begin
        if(btn_c_pin_i) begin
            if(rst_btn_time_cnt == `RST_BTN_TIME_MAX_CNT - 1) begin
                rst <= 1;
                rst_btn_time_cnt = rst_btn_time_cnt;
            end else begin
                rst_btn_time_cnt <= rst_btn_time_cnt + 1;
                rst <= 0;
            end
        end else begin
            rst_btn_time_cnt <= 0;
            rst <= 0;
        end
    end

 
 endmodule //enc_btn