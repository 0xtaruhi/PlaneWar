/*
 * Description  : Top file of the project
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 18:54:01
 * LastEditTime : 2021-11-01 20:47:38
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\top.v
 */

 module top (
     input  wire clk_100MHz
 );

    wire clk_50MHz;

    clk_wiz_0 clk_wiz_0_dut(.clk_i(clk_100MHz), .clk_50MHz(clk_50MHz));
 
 endmodule //top