/*
 * Description  : My Craft
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-02 14:37:42
 * LastEditTime : 2021-11-03 15:09:18
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\me.v
 */
`include "../header/define.v"
module me (
        input  wire                          clk_run,
        input  wire                          clk_vga,
        input  wire                          rst,
        input  wire                          en_i,
        input  wire                          v_sync_i,
        input  wire [       `H_DISP_LEN-1:0] req_x_addr_i,
        input  wire [       `V_DISP_LEN-1:0] req_y_addr_i,
        input  wire                          move_en_i,     //移动使能
        input  wire [1:0]                    direct_i,      //移动的方块

        // output reg                           moving_o,      //正在移动
        // output reg  [`OBJ_X_POS_BIT_LEN-1:0] x_pos,
        // output reg  [`OBJ_Y_POS_BIT_LEN-1:0] y_pos,
        output wire [  `COLOR_RGB_DEPTH-1:0] vga_rgb_o,
        output wire                          vga_alpha_o        //当前色块是透明的
    );

    // localparam defines
    localparam SPEED = 2;
    localparam DOWN_BOUND = `V_DISP - `ME_Y_SIZE - SPEED;
    localparam RIGHT_BOUND = `H_DISP - `ME_X_SIZE - SPEED;
    localparam UP_BOUND = SPEED;
    localparam LEFT_BOUND = SPEED;

    // position register
    reg [`OBJ_X_POS_BIT_LEN-1:0] x_pos;
    reg [`OBJ_Y_POS_BIT_LEN-1:0] y_pos;

    // display signal
    wire in_req_area;
    assign in_req_area = en_i && (req_x_addr_i >= x_pos)
           && (req_x_addr_i < x_pos + `ME_X_SIZE)
           && (req_y_addr_i >= y_pos)
           && (req_y_addr_i < y_pos + `ME_Y_SIZE);        // 这部分的组合逻辑或许可以优化

    wire bram_en;
    assign bram_en = in_req_area;

    wire bram_clr;
    assign bram_clr = ~v_sync_i;

    reg [`ME_BRAM_DEPTH_BIT_LEN-1:0] bram_addr_cnt = 0;     // bram地址计数寄存器
    always@(posedge clk_vga or posedge rst or posedge bram_clr) begin
        if(rst | bram_clr) begin
            bram_addr_cnt <= 0;
        end
        else begin
            if(bram_en) begin
                bram_addr_cnt <= bram_addr_cnt + 1;
            end
            else begin
                bram_addr_cnt <= bram_addr_cnt;
            end
        end
    end

    wire [`COLOR_GRAY_DEPTH-1:0] bram_gray;
    wire                         bram_alpha;
    bram_me1 bram_me1_dut
             (
                 .clka(clk_vga),
                 .ena(bram_en),
                 .addra(bram_addr_cnt),
                 .douta({bram_gray, bram_alpha})
             );
    assign vga_rgb_o = en_i ? {3{bram_gray}} : 0;
    assign vga_alpha_o = en_i ? bram_alpha : 0;

    // moving control
    always @(posedge clk_run or posedge rst) begin
        if(rst) begin
            x_pos <= `ME_DEFAULT_X_POS;
            y_pos <= `ME_DEFAULT_Y_POS;
            // moving_o <= 0;
        end
        else begin
            if(en_i && move_en_i) begin
                case(direct_i)
                    `UP: begin
                        if(y_pos > UP_BOUND) begin
                            y_pos <= y_pos - 1;
                            // moving_o <= 1;
                        end
                        else begin
                            y_pos <= y_pos;
                            // moving_o <= 0;
                        end
                        x_pos <= x_pos;
                    end
                    `DOWN: begin
                        if(y_pos < DOWN_BOUND) begin
                            y_pos <= y_pos + 1;
                            // moving_o <= 1;
                        end
                        else begin
                            y_pos <= y_pos;
                            // moving_o <= 0;
                        end
                        x_pos <= x_pos;
                    end
                    `LEFT: begin
                        if(x_pos > LEFT_BOUND) begin
                            x_pos <= x_pos - 1;
                            // moving_o <= 1;
                        end
                        else begin
                            x_pos <= x_pos;
                            // moving_o <= 0;
                        end
                        y_pos <= y_pos;
                    end
                    `RIGHT: begin
                        if(x_pos < RIGHT_BOUND) begin
                            x_pos <= x_pos + 1;
                            // moving_o <= 1;
                        end
                        else begin
                            x_pos <= x_pos;
                            // moving_o <= 0;
                        end
                        y_pos <= y_pos;
                    end
                endcase
            end
            else begin
                x_pos <= x_pos;
                y_pos <= y_pos;
                // moving_o <= 0;
            end
        end
    end

endmodule //me