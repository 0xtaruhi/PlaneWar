/*
 * Description  : My Craft
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-02 14:37:42
 * LastEditTime : 2021-11-09 14:56:18
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
        input  wire                          move_en_i,     //move enable
        input  wire [1:0]                    direct_i,      //direction of move

        // output reg                           moving_o,      //
        output wire [`OBJ_X_POS_BIT_LEN-1:0] x_pos_o,
        output wire [`OBJ_Y_POS_BIT_LEN-1:0] y_pos_o,
        output wire [  `COLOR_RGB_DEPTH-1:0] vga_rgb_o,
        output wire                          vga_alpha_o        //current pixel's alpha
    );

    // localparam defines
    parameter SPEED = 5;
    localparam DOWN_BOUND = `V_DISP - `ME_Y_SIZE - SPEED;
    localparam RIGHT_BOUND = `H_DISP - `ME_X_SIZE - SPEED;
    localparam UP_BOUND = SPEED;
    localparam LEFT_BOUND = SPEED;

    // position register
    reg  [    `OBJ_X_POS_BIT_LEN-1:0] x_pos;
    reg  [    `OBJ_Y_POS_BIT_LEN-1:0] y_pos;
    reg  [`ME_BRAM_DEPTH_BIT_LEN-1:0] bram_addr_cnt = 0;     // bram address counter
    wire [     `COLOR_GRAY_DEPTH-1:0] bram_gray_1;
    wire [     `COLOR_GRAY_DEPTH-1:0] bram_gray_2;
    wire [     `COLOR_GRAY_DEPTH-1:0] bram_gray_destroy_1;
    wire [     `COLOR_GRAY_DEPTH-1:0] bram_gray_destroy_2;
    wire [     `COLOR_GRAY_DEPTH-1:0] bram_gray_destroy_3;
    wire                              bram_alpha_1;
    wire                              bram_alpha_2;
    wire [        `ME_BRAM_WIDTH-1:0] bram_info;
    reg                               image_normal_id;
    reg  [                       5:0] cnt_image_change;
    wire                              bram_clr;
    wire                              in_req_area;


    assign x_pos_o = x_pos;
    assign y_pos_o = y_pos;

    // display signal
    assign in_req_area = en_i && (req_x_addr_i >= x_pos)
           && (req_x_addr_i < x_pos + `ME_X_SIZE)
           && (req_y_addr_i >= y_pos)
           && (req_y_addr_i < y_pos + `ME_Y_SIZE); 

    // bram
    assign bram_clr = ~v_sync_i;
    always@(posedge clk_vga or posedge rst or posedge bram_clr) begin
        if(rst | bram_clr) begin
            bram_addr_cnt <= 0;
        end
        else begin
            if(in_req_area) begin
                bram_addr_cnt <= bram_addr_cnt + 1;
            end
            else begin
                bram_addr_cnt <= bram_addr_cnt;
            end
        end
    end
    // bram output
    assign {bram_alpha_1, bram_gray_1, bram_alpha_2, bram_gray_2,
             bram_gray_destroy_1, bram_gray_destroy_2,bram_gray_destroy_3}
             = bram_info;
    //bram instance
    bram_me bram_me_dut
             (
                 .clka(clk_vga),
                 .ena(1'b1),
                 .addra(bram_addr_cnt),
                 .douta(bram_info)
             );
    // image changing
    always @(posedge clk_run or posedge rst) begin
        if(rst) begin
            cnt_image_change <= 0;
            image_normal_id <= 0;
        end else begin
            if(cnt_image_change == 6'b111111) begin
                image_normal_id <= ~image_normal_id;
                cnt_image_change <= 0;
            end else begin
                cnt_image_change <= cnt_image_change + 1;
            end
        end
    end
    // display output
    assign vga_rgb_o = en_i ? (image_normal_id == 1'b0 ?
                {3{bram_gray_1}} :{3{bram_gray_2}}) : 0;
    assign vga_alpha_o = en_i ? (image_normal_id == 1'b0 ?
                 bram_alpha_1 : bram_alpha_2) : 0;

    // moving control
    always @(posedge clk_run or posedge rst) begin
        if(rst) begin
            x_pos <= `ME_DEFAULT_X_POS;
            y_pos <= `ME_DEFAULT_Y_POS;
        end
        else begin
            if(en_i && move_en_i) begin
                case(direct_i)
                    `UP: begin
                        if(y_pos > UP_BOUND) begin
                            y_pos <= y_pos - 1;
                        end
                        else begin
                            y_pos <= y_pos;
                        end
                        x_pos <= x_pos;
                    end
                    `DOWN: begin
                        if(y_pos < DOWN_BOUND) begin
                            y_pos <= y_pos + 1;
                        end
                        else begin
                            y_pos <= y_pos;
                        end
                        x_pos <= x_pos;
                    end
                    `LEFT: begin
                        if(x_pos > LEFT_BOUND) begin
                            x_pos <= x_pos - 1;
                        end
                        else begin
                            x_pos <= x_pos;
                        end
                        y_pos <= y_pos;
                    end
                    `RIGHT: begin
                        if(x_pos < RIGHT_BOUND) begin
                            x_pos <= x_pos + 1;
                        end
                        else begin
                            x_pos <= x_pos;
                        end
                        y_pos <= y_pos;
                    end
                endcase
            end
            else begin
                x_pos <= x_pos;
                y_pos <= y_pos;
            end
        end
    end

endmodule //me
