/*
 * Description  : 
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-08 11:41:15
 * LastEditTime : 2021-11-08 18:17:52
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\enemy1.v
 */
`include "../header/define.v"
module enemy1 (
    input  wire                        clk,
    input  wire                        rst,

    output wire                        rgb_alpha_o,
    output wire [`COLOR_RGB_DEPTH-1:0] vga_rgb_o
);

    wire bram_en;
    bram_enemy1
        bram_enemy1_dut
        (
            .clk(clk),
            .ena(bram_en),
            .addra(),
            .douta()
        );

endmodule //enemy1