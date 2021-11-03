/*
 * Description  : Driver of buttons on board
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-03 11:45:47
 * LastEditTime : 2021-11-03 11:48:04
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\dri_btn.v
 */

 module dri_btn (
     input wire clk,
     input wire en_i,

     output wire btn_c_o,
     output wire btn_u_o,
     output wire btn_d_o,
     output wire btn_l_o,
     output wire btn_r_o
 );
 
 endmodule //dri_btn