/*
 * Description  : Header file of the project
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 20:24:39
 * LastEditTime : 2021-11-16 14:29:36
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\header\define.v
 */
`ifndef _DEFINE_V_
`define _DEFINE_V_
// VGA settings (800*600 60Hz), clk=40MHz
`define H_TOTAL                             1056
`define H_SYNC                              128
`define H_BACK                              88
`define H_DISP                              800
`define H_FRONT                             40
`define H_START                             (`H_SYNC + `H_BACK)
`define H_END                               (`H_START + `H_DISP)
`define H_BIT_LEN                           11
`define H_DISP_LEN                          10
`define V_TOTAL                             628
`define V_SYNC                              4
`define V_BACK                              23
`define V_DISP                              600
`define V_FRONT                             1
`define V_START                             (`V_SYNC + `V_BACK)
`define V_END                               (`V_START + `V_DISP)
`define V_BIT_LEN                           10
`define V_DISP_LEN                          10

// output color depth
`define COLOR_R_DEPTH                       4
`define COLOR_G_DEPTH                       4
`define COLOR_B_DEPTH                       4
`define COLOR_RGB_DEPTH                     (`COLOR_R_DEPTH + `COLOR_G_DEPTH + `COLOR_B_DEPTH)
`define COLOR_GRAY_DEPTH                    4

// background
`define BG_COLOR_R                          {`COLOR_R_DEPTH'hc}
`define BG_COLOR_G                          {`COLOR_G_DEPTH'hc}
`define BG_COLOR_B                          {`COLOR_B_DEPTH'hc}

// rom
`define ROM_READ_DELAY                      2        //BRAMs have a 2 clock cycle delay

//clock
`define FREQ_SYS                            100000000
`define FREQ_RUN                            250
//`define CNT_MAX_RUN                         833333
`define CNT_MAX_RUN                         ((`FREQ_SYS / 2) / `FREQ_RUN)
`define CNT_MAX_RUN_BIT_LEN                 18

// objects
`define OBJ_X_POS_BIT_LEN                   10
`define OBJ_Y_POS_BIT_LEN                   10

// ME
// direction
`define UP                                  2'b00
`define DOWN                                2'b01
`define LEFT                                2'b10
`define RIGHT                               2'b11
// size, pos, bram
`define ME_X_SIZE                           102
`define ME_Y_SIZE                           126
`define ME_DEFAULT_X_POS                    349
`define ME_DEFAULT_Y_POS                    470
`define ME_BRAM_DEPTH                       12852
`define ME_BRAM_DEPTH_BIT_LEN               14
`define ME_BRAM_WIDTH                       22

// bullet
`define BULLET_NUM                          8
`define BULLET_NUM_BIT_LEN                  3
`define BULLET_WIDTH                        5
`define BULLET_HEIGHT                       11
`define BULLET_SINGLE_X_OFFSET              51
`define BULLET_SINGLE_Y_OFFSET              0 
`define BULLET_DOUBLE_X_OFFSET_LEFT         16
`define BULLET_LEFT2CENTER                  (`BULLET_DOUBLE_X_OFFSET_LEFT - `BULLET_SINGLE_X_OFFSET)
`define BULLET_DOUBLE_X_OFFSET_RIGHT        80
`define BULLET_RIGHT2CENTER                 (`BULLET_DOUBLE_X_OFFSET_RIGHT - `BULLET_SINGLE_X_OFFSET)
`define BULLET_DOUBLE_Y_OFFSET              45
`define BULLET_CENTER                       0
`define BULLET_LEFT                         1
`define BULLET_RIGHT                        2
`define BULLET_MODE_SINGLE                  1'b0
`define BULLET_MODE_DOUBLE                  1'b1
`define BULLET_SHOOT_FREQ                   5
`define CNT_MAX_SHOOT                       (`FREQ_RUN / `BULLET_SHOOT_FREQ)
`define CNT_MAX_SHOOT_BIT_LEN               6
`define BULLET_DOUBLE_COLOR                 12'h236
`define BULLET_SINGLE_COLOR                 12'ha62

`define ENEMY1_X_SIZE                       57
`define ENEMY1_Y_SIZE                       43
`define ENEMY1_BRAM_DEPTH                   2451
`define ENEMY1_BRAM_DEPTH_BIT_LEN           12
`define ENEMY1_BRAM_WIDTH                   18
`define ENEMY1_NUM                          8
`define ENEMY1_NUM_BIT_LEN                  4
`define ENEMY1_SPEED_LOW                    1
`define ENEMY1_SPEED_MIDDLE                 2
`define ENEMY1_SPEED_HIGH                   4
`define ENEMY1_SPEED_REG_WIDTH              2
`define ENEMY1_STATE_REG_WIDTH              2
`define ENEMY1_TRIGGER_FREQ                 2
`define ENEMY1_CNT_MAX_TRIGGER              (`FREQ_RUN / `ENEMY1_TRIGGER_FREQ)
`define ENEMY1_CNT_MAX_TRIGGER_BIT_LEN      7
`define ENEMY1_DOWN_FREQ                    3
`define ENEMY1_CNT_MAX_DOWN                 (`FREQ_SYS / `ENEMY1_DOWN_FREQ)
`define ENEMY1_CNT_MAX_DOWN_BIT_LEN         25

`define ENEMY2_X_SIZE                       69
`define ENEMY2_Y_SIZE                       99
`define ENEMY2_BRAM_DEPTH                   6831
`define ENEMY3_X_SIZE                       165
`define ENEMY3_Y_SIZE                       261
`define ENEMY3_BRAM_DEPTH                   43065

`endif