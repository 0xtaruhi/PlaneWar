/*
 * Description  : Header file of the project
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 20:24:39
 * LastEditTime : 2021-11-21 14:29:06
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

// random
`define RAND_WIDTH                          16
`define RAND_SEED                           16'h3ab6

// game control
`define GAME_STATUS_BIT_LEN                 3

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
// `define FREQ_RUN                            250
`define FREQ_RUN                            100
//`define CNT_MAX_RUN                         833333
`define CNT_MAX_RUN                         ((`FREQ_SYS / 2) / `FREQ_RUN)
// `define CNT_MAX_RUN_BIT_LEN                 18
`define CNT_MAX_RUN_BIT_LEN                 20

// objects
`define OBJ_X_POS_BIT_LEN                   10
`define OBJ_Y_POS_BIT_LEN                   10
`define OBJ_X_SIZE_BIT_LEN                  9
`define OBJ_Y_SIZE_BIT_LEN                  9

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
`define ME_SPEED                            10

// bullet
`define BULLET_NUM                          4
`define BULLET_NUM_BIT_LEN                  2
`define BULLET_SPEED                        30
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
`define CNT_MAX_SHOOT_BIT_LEN               5
`define BULLET_DOUBLE_COLOR                 12'h236
`define BULLET_SINGLE_COLOR                 12'ha62

`define ENEMY_SPEED_LOW                     1
`define ENEMY_SPEED_MIDDLE                  2
`define ENEMY_SPEED_HIGH                    3
`define ENEMY_SPEED_REG_WIDTH               2
`define MAX_ENEMY_NUM_BIT_LEN               4
`define ENEMY_DOWN_FREQ                     20
`define ENEMY_CNT_MAX_DOWN                  (`FREQ_SYS / `ENEMY_DOWN_FREQ)
`define ENEMY_CNT_MAX_DOWN_BIT_LEN          23


 // enemy1
`define ENEMY1_X_SIZE                       57
`define ENEMY1_Y_SIZE                       43
`define ENEMY1_BRAM_DEPTH                   2451
`define ENEMY1_BRAM_DEPTH_BIT_LEN           12
`define ENEMY1_BRAM_WIDTH                   20
`define ENEMY1_NUM                          8
`define ENEMY1_NUM_BIT_LEN                  4
`define ENEMY1_SPEED_LOW                    2
`define ENEMY1_SPEED_MIDDLE                 5
`define ENEMY1_SPEED_HIGH                   7
// `define ENEMY1_SPEED_REG_WIDTH              2
`define ENEMY1_STATE_REG_WIDTH              3
`define ENEMY1_TRIGGER_FREQ                 2
`define ENEMY1_CNT_MAX_TRIGGER              (`FREQ_RUN / `ENEMY1_TRIGGER_FREQ)
`define ENEMY1_CNT_MAX_TRIGGER_BIT_LEN      7
`define ENEMY1_DOWN_FREQ                    20
`define ENEMY1_CNT_MAX_DOWN                 (`FREQ_SYS / `ENEMY1_DOWN_FREQ)
`define ENEMY1_CNT_MAX_DOWN_BIT_LEN         23
`define ENEMY1_SLOW_RAND_OFFSET             0

`define ENEMY2_X_SIZE                       69
`define ENEMY2_Y_SIZE                       95
`define ENEMY2_BRAM_WIDTH                   25
`define ENEMY2_BRAM_DEPTH                   6555
`define ENEMY2_BRAM_DEPTH_BIT_LEN           13
`define ENEMY2_NUM                          4
`define ENEMY2_NUM_BIT_LEN                  2
`define ENEMY2_SPEED                        2
`define ENEMY2_STATE_REG_WIDTH              3
`define ENEMY2_TRIGGER_FREQ                 1
`define ENEMY2_CNT_MAX_TRIGGER              (`FREQ_RUN / `ENEMY2_TRIGGER_FREQ)
`define ENEMY2_CNT_MAX_TRIGGER_BIT_LEN      8
`define ENEMY2_DOWN_FREQ                    20
`define ENEMY2_CNT_MAX_DOWN                 (`FREQ_SYS / `ENEMY1_DOWN_FREQ)
`define ENEMY2_CNT_MAX_DOWN_BIT_LEN         23
`define ENEMY2_LIFE                         2
`define ENEMY2_LIFE_BIT_LEN                 2
`define ENEMY2_RAND_OFFSET                  2
 
// enemy3
`define ENEMY3_X_SIZE                       165
`define ENEMY3_Y_SIZE                       261
`define ENEMY3_BRAM_WIDTH                   20
`define ENEMY3_BRAM_DEPTH                   43065
`define ENEMY3_BRAM_DEPTH_BIT_LEN           16
`define ENEMY3_NUM                          1
`define ENEMY3_NUM_BIT_LEN                  1
`define ENEMY3_STATE_REG_WIDTH              3
`define ENEMY3_LIFE                         5
`define ENEMY3_LIFE_BIT_LEN                 3
`define ENEMY3_TRIGGER_FREQ                 5 //to avoid "real" type, it's 100 times to real frequency
`define ENEMY3_CNT_MAX_TRIGGER              (`FREQ_RUN / `ENEMY3_TRIGGER_FREQ) * 100
`define ENEMY3_CNT_MAX_TRIGGER_BIT_LEN      11
`define ENEMY3_DOWN_FREQ                    20
`define ENEMY3_SPEED                        1
`define ENEMY3_RAND_OFFSET                  3

// bomb
`define BOMB_X_SIZE                         60
`define BOMB_Y_SIZE                         107
`define BOMB_BRAM_WIDTH                     13
`define BOMB_BRAM_DEPTH                     6420
`define BOMB_BRAM_DEPTH_BIT_LEN             13
`define BOMB_NUM                            1
`define BOMB_NUM_BIT_LEN                    1
`define BOMB_TRIGGER_FREQ                   10 // reql frequency is 0.02Hz
`define BOMB_CNT_MAX_TRIGGER                (`FREQ_RUN / `BOMB_TRIGGER_FREQ) * 100
`define BOMB_CNT_MAX_TRIGGER_BIT_LEN        13
`define BOMB_SPEED                          3
`define BOMB_RAND_OFFSET                    4
`endif