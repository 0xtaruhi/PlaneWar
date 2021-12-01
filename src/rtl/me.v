/*
 * Description  : My Craft
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-02 14:37:42
 * LastEditTime : 2021-11-24 16:59:02
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
        input  wire                          crash_me_enemy_i,

        // output reg                           moving_o,      //
        output wire [`OBJ_X_POS_BIT_LEN-1:0] x_pos_o,
        output wire [`OBJ_Y_POS_BIT_LEN-1:0] y_pos_o,
        output wire [  `COLOR_RGB_DEPTH-1:0] vga_rgb_o,
        output wire                          vga_alpha_o        //current pixel's alpha
        // output wire                          me_normal_o
    );

    /*
        COE file infomation:
        total: 20btis
        ('alpha', me1.get_alphainfo())
        ('gray', me1.get_grayinfo())
        ('alpha', me2.get_alphainfo())
        ('gray', me2.get_grayinfo())
        ('alpha', me_destroy_1.get_alphainfo())
        ('gray', me_destroy_1.get_grayinfo())
        ('alpha', me_destroy_3.get_get_alphainfo())
        ('gray', me_destroy_3.get_grayinfo())
    */

    // localparam defines
    parameter SPEED = `ME_SPEED;
    localparam DOWN_BOUND = `V_DISP - `ME_Y_SIZE - SPEED;
    localparam RIGHT_BOUND = `H_DISP - `ME_X_SIZE - SPEED;
    localparam UP_BOUND = SPEED;
    localparam LEFT_BOUND = SPEED;
    localparam STATE_N1       = 3'b001;
    localparam STATE_N2       = 3'b010;
    localparam STATE_DOWN1    = 3'b011;
    localparam STATE_DOWN2    = 3'b111;
    localparam STATE_UNVISUAL = 3'b110;

    // position register
    reg  [    `OBJ_X_POS_BIT_LEN-1:0] x_pos;
    reg  [    `OBJ_Y_POS_BIT_LEN-1:0] y_pos;
    reg  [    `OBJ_Y_POS_BIT_LEN-1:0] displocked_y_pos;
    reg  [`ME_BRAM_DEPTH_BIT_LEN-1:0] bram_addr_cnt = 0;     // bram address counter
    wire [     `COLOR_GRAY_DEPTH-1:0] bram_gray_1;
    wire [     `COLOR_GRAY_DEPTH-1:0] bram_gray_2;
    wire [     `COLOR_GRAY_DEPTH-1:0] bram_gray_destroy_1;
    wire [     `COLOR_GRAY_DEPTH-1:0] bram_gray_destroy_2;
    // wire [     `COLOR_GRAY_DEPTH-1:0] bram_gray_destroy_3;
    wire                              bram_alpha_1;
    wire                              bram_alpha_2;
    wire                              bram_alpha_destroy_1;
    wire                              bram_alpha_destroy_2;
    wire [        `ME_BRAM_WIDTH-1:0] bram_info;
    // reg                               image_normal_id;
    // reg  [                       5:0] cnt_image_change;
    reg  [    `ENEMY_CNT_MAX_DOWN_BIT_LEN-1:0] cnt_down;
    reg                                        state_change;
    wire                              bram_clr;
    wire                              in_req_area;
    reg  [   `ME_STATE_REG_WIDTH-1:0] state;
    reg  [   `ME_STATE_REG_WIDTH-1:0] n_state;
    reg  [      `COLOR_RGB_DEPTH-1:0] vga_rgb;
    reg                               vga_alpha;


    assign x_pos_o = x_pos;
    assign y_pos_o = y_pos;
    // assign me_normal_o = state == STATE_N1 || state == STATE_N2;

    always @(posedge clk_vga or posedge rst) begin
        if(rst) begin
            displocked_y_pos <= 0;
        end else begin
            if(~v_sync_i) begin
                displocked_y_pos <= y_pos;
            end else begin
                displocked_y_pos <= displocked_y_pos;
            end
        end
    end

    always @(posedge clk_vga or posedge rst)begin
        if(rst) begin
            cnt_down <= 0;
        end else begin
            if(cnt_down == `ENEMY_CNT_MAX_DOWN - 1)begin
                state_change <= 1;
                cnt_down <= 0;
            end else begin
                state_change <= 0;
                cnt_down <= cnt_down + 1;
            end
        end
    end

    always @(posedge clk_vga or posedge rst) begin
        if(rst) begin
            state <= STATE_N1;
        end else begin
            state <= n_state;
        end
    end

    // display signal
    assign in_req_area = en_i && (req_x_addr_i >= x_pos)
           && (req_x_addr_i < x_pos + `ME_X_SIZE)
           && (req_y_addr_i >= displocked_y_pos)
           && (req_y_addr_i < displocked_y_pos + `ME_Y_SIZE); 

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
             bram_alpha_destroy_1, bram_gray_destroy_1,
             bram_alpha_destroy_2,bram_gray_destroy_2}
             = bram_info;
    //bram instance
    bram_me bram_me_dut
             (
                 .clka(clk_vga),
                 .ena(1'b1),
                 .addra(bram_addr_cnt),
                 .douta(bram_info)
             );
    
    assign vga_rgb_o = vga_rgb;
    assign vga_alpha_o = vga_alpha;

    always @(*) begin
        if(in_req_area) begin
            case(state)
                STATE_N1: begin
                    vga_alpha = bram_alpha_1;
                    vga_rgb   = {3{bram_gray_1}};
                end
                STATE_N2: begin
                    vga_alpha = bram_alpha_2;
                    vga_rgb   = {3{bram_gray_2}};
                end
                STATE_DOWN1: begin
                    vga_alpha = bram_alpha_destroy_1;
                    vga_rgb   = {3{bram_gray_destroy_1}};
                end
                STATE_DOWN2: begin
                    vga_alpha = bram_alpha_destroy_2;
                    vga_rgb   = {3{bram_gray_destroy_2}};
                end
                default: begin
                    vga_alpha = 0;
                    vga_rgb   = 0;
                end
            endcase
        end else begin
            vga_alpha = 0;
            vga_rgb   = 0;
        end
    end

    always @(*) begin
        case(state)
            STATE_N1 :
                n_state = crash_me_enemy_i ? STATE_DOWN1 : state_change ? STATE_N2 : STATE_N1;
            STATE_N2 :
                n_state = crash_me_enemy_i ? STATE_DOWN1 : state_change ? STATE_N1 : STATE_N2;
            STATE_DOWN1 :
                n_state = state_change ? STATE_DOWN2 : STATE_DOWN1;
            STATE_DOWN2:
                n_state = state_change ? STATE_UNVISUAL : STATE_DOWN2;
            STATE_UNVISUAL :
                n_state = STATE_UNVISUAL;
            default:
                n_state = STATE_N1;
        endcase
    end


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
                            y_pos <= y_pos - SPEED;
                        end
                        else begin
                            y_pos <= y_pos;
                        end
                        x_pos <= x_pos;
                    end
                    `DOWN: begin
                        if(y_pos < DOWN_BOUND) begin
                            y_pos <= y_pos + SPEED;
                        end
                        else begin
                            y_pos <= y_pos;
                        end
                        x_pos <= x_pos;
                    end
                    `LEFT: begin
                        if(x_pos > LEFT_BOUND) begin
                            x_pos <= x_pos - SPEED;
                        end
                        else begin
                            x_pos <= x_pos;
                        end
                        y_pos <= y_pos;
                    end
                    `RIGHT: begin
                        if(x_pos < RIGHT_BOUND) begin
                            x_pos <= x_pos + SPEED;
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
