/*
 * Description  : Header file of the project
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 20:24:39
 * LastEditTime : 2021-11-01 23:32:26
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\header\define.v
 */
// VGA settings (800*600 50Hz)
`define H_TOTAL     1056
`define H_SYNC      128
`define H_BACK      88
`define H_DISP      800
`define H_FRONT     40
`define H_START     216
`define H_END       1016
`define H_BIT_LEN   11
`define H_DISP_LEN  10
`define V_TOTAL     628
`define V_SYNC      4
`define V_BACK      23
`define V_DISP      600
`define V_FRONT     1
`define V_START     27
`define V_END       627
`define V_BIT_LEN   10
`define V_DISP_LEN  10

 // output color depth
 `define COLOR_R_DEPTH 4
 `define COLOR_G_DEPTH 4
 `define COLOR_B_DEPTH 4

// background
`define BG_COLOR_R  `COLOR_R_DEPTH'd12
`define BG_COLOR_G  `COLOR_G_DEPTH'd12
`define BG_COLOR_B  `COLOR_B_DEPTH'd12
