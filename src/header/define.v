/*
 * Description  : Header file of the project
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 20:24:39
 * LastEditTime : 2021-11-03 22:42:17
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\header\define.v
 */
`ifndef _DEFINE_V_
`define _DEFINE_V_
// VGA settings (800*600 60Hz), clk=40MHz
`define H_TOTAL     1056
`define H_SYNC      128
`define H_BACK      88
`define H_DISP      800
`define H_FRONT     40
`define H_START     (`H_SYNC + `H_BACK)
`define H_END       (`H_START + `H_DISP)
`define H_BIT_LEN   11
`define H_DISP_LEN  10
`define V_TOTAL     628
`define V_SYNC      4
`define V_BACK      23
`define V_DISP      600
`define V_FRONT     1
`define V_START     (`V_SYNC + `V_BACK)
`define V_END       (`V_START + `V_DISP)
`define V_BIT_LEN   10
`define V_DISP_LEN  10

// output color depth
`define COLOR_R_DEPTH 4
`define COLOR_G_DEPTH 4
`define COLOR_B_DEPTH 4
`define COLOR_RGB_DEPTH (`COLOR_R_DEPTH + `COLOR_G_DEPTH + `COLOR_B_DEPTH)
`define COLOR_GRAY_DEPTH 4

// background
`define BG_COLOR_R  {`COLOR_R_DEPTH'hc}
`define BG_COLOR_G  {`COLOR_G_DEPTH'hc}
`define BG_COLOR_B  {`COLOR_B_DEPTH'hc}

// rom
`define ROM_READ_DELAY 2        //BRAMs have a 2 clock cycle delay

//clock
`define FREQ_SYS    100000000
`define FREQ_RUN    60
`define CNT_MAX_RUN 833333
`define CNT_MAX_RUN_BIT_LEN  20

// objects
`define OBJ_X_POS_BIT_LEN 10
`define OBJ_Y_POS_BIT_LEN 10

// ME
// direction
`define UP               2'b00
`define DOWN             2'b01
`define LEFT             2'b10
`define RIGHT            2'b11
`define ME_X_SIZE        102
`define ME_Y_SIZE        126
`define ME_DEFAULT_X_POS 349
`define ME_DEFAULT_Y_POS 470
`define ME_BRAM_DEPTH    12852
`define ME_BRAM_DEPTH_BIT_LEN 14
`endif