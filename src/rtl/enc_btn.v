/*
 * Description  : Encoder of buttons on board
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-03 11:45:47
 * LastEditTime : 2021-11-03 22:39:26
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\enc_btn.v
 */

 `include "../header/define.v"
 module enc_btn (
     input  wire clk,
     
     input  wire btn_l_pin_i,
     input  wire btn_r_pin_i,
     input  wire btn_u_pin_i,
     input  wire btn_d_pin_i,

     output reg  move_en_o,
     output reg  direct_o
 );

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
 
 endmodule //enc_btn