/*
 * Description  : 
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-08 11:41:15
 * LastEditTime : 2021-11-10 19:56:10
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\enemy1.v
 */
`include "../header/define.v"
module enemy1 (
    input  wire                        clk_run,
    input  wire                        clk_vga,
    input  wire                        rst,
    input  wire                        en_i,
    input  wire                        v_sync_i,
    input  wire [     `H_DISP_LEN-1:0] req_x_addr_i,
    input  wire [     `H_DISP_LEN-1:0] req_y_addr_i,

    output wire                        rgb_alpha_o,
    output wire [`COLOR_RGB_DEPTH-1:0] vga_rgb_o
);

    /*
        COE file infomation:
        total: 18bits
            ('alpha', enemy1.get_alphainfo())
            ('gray', enemy1.get_grayinfo())
            ('gray', enemy1_down1.get_grayinfo())
            ('gray', enemy1_down2.get_grayinfo())
            ('alpha', enemy1_down3.get_alphainfo())
            ('gray', enemy1_down3.get_grayinfo()))
    */
    // parameters
    localparam SPEED_STOP_CODE = 2'b00;
    localparam SPEED_LOW_CODE = 2'b01;
    localparam SPEED_MIDDLE_CODE = 2'b11;
    localparam SPEED_HIGH_CODE = 2'b10;

    // registers and wires
    // -- bram
    reg  [`ENEMY1_BRAM_DEPTH_BIT_LEN-1:0] bram_addr;
    reg  [`ENEMY1_BRAM_DEPTH_BIT_LEN-1:0] bram_addr_unit [`ENEMY1_NUM-1:0];
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_normal;
    wire                                  bram_alpha_normal;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_down1;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_down2;
    wire                                  bram_alpha_down3;
    wire [         `COLOR_GRAY_DEPTH-1:0] bram_gray_down3;
    wire [        `ENEMY1_BRAM_WIDTH-1:0] bram_info; 
    // enemy1 position and speed
    /* when the enemy is at the top of the screen, it need to be showed partly,
       to make the postion always positive, there are two kinds of y-position
       postion on the screen is the real_...
       the virtual position is the ori_...
       real_... = ori_... - ENEMY1_Y_SIZE
    */
    reg  [        `OBJ_X_POS_BIT_LEN-1:0] x_pos_unit       [`ENEMY1_NUM-1:0];
    reg  [        `OBJ_Y_POS_BIT_LEN-1:0] fixed_y_pos_unit [`ENEMY1_NUM-1:0];
    wire [        `OBJ_Y_POS_BIT_LEN-1:0] real_y_pos_unit  [`ENEMY1_NUM-1:0];
    reg  [       `ENEMY1_NUM_BIT_LEN-1:0] trigger_idx;
    reg                                   trigger;
    reg  [   `ENEMY1_SPEED_REG_WIDTH-1:0] speed_unit       [`ENEMY1_NUM-1:0];
    reg                                   visible          [`ENEMY1_NUM-1:0];
    // trigger 
    reg  [`ENEMY1_CNT_MAX_TRIGGER_BIT_LEN-1:0] cnt_trigger;
    //fixed req addr
    wire [                   `V_DISP-1:0] fixed_req_y_addr;
    //rgb
    wor                                   rgb_alpha;
    // wire bram_en;
    bram_enemy1 bram_enemy1_dut
        (
            .clk(clk),
            .ena(1'b1),
            .addra(bram_addr_cnt),
            .douta(bram_info)
        );
    assign {bram_alpha_normal, bram_gray_normal,
            bram_gray_down1, bram_gray_down2,
            bram_alpha_down3, bram_gray_down3} = bram_info;
    assign fixed_req_y_addr = req_y_addr_i + `ENEMY1_Y_SIZE;

    always @(posedge clk_run or posedge rst)begin
        if(rst) begin
            cnt_trigger <= 0;
            trigger_idx <= 0;
            trigger     <= 0;
        end else begin
            if(cnt_trigger == `ENEMY1_CNT_MAX_TRIGGER - 1)begin
                cnt_trigger <= 0;
                trigger     <= 1;
                if(trigger_idx == `ENEMY1_NUM - 1) begin
                    trigger_idx <= 0;
                end else begin
                    trigger_idx <= trigger_idx + 1;
                end
            end else begin
                cnt_trigger <= cnt_trigger + 1;
                trigger     <= 0;
            end
        end
    end
    
    genvar i;
    generate 
        for(i=0;i<`ENEMY1_NUM;i=i+1) begin: ENEMY1_LOOP
            assign real_y_pos_unit[i] = (fixed_y_pos_unit[i] >= `ENEMY1_Y_SIZE) ?
                                    fixed_y_pos_unit[i] - `ENEMY1_Y_SIZE : 
                                    {`OBJ_Y_POS_BIT_LEN{1'b1}};
            always @(posedge clk_run or posedge rst)begin
                if(rst) begin
                    x_pos_unit[i]       <= 0;
                    fixed_y_pos_unit[i] <= 0;
                    visible[i]          <= 0;
                    speed_unit[i]       <= SPEED_STOP_CODE;
                end else begin
                    if(visible[i]) begin
                        if(fixed_y_pos_unit[i] >= `V_DISP + `ENEMY1_Y_SIZE) begin
                            visible[i] <= 0;
                            speed_unit[i] <= SPEED_STOP_CODE;
                        end else begin
                            case(speed_unit[i])
                                SPEED_STOP_CODE:
                                    fixed_y_pos_unit[i] <= fixed_y_pos_unit[i];
                                SPEED_LOW_CODE:
                                    fixed_y_pos_unit[i] <= fixed_y_pos_unit[i] + `ENEMY1_SPEED_LOW;
                                SPEED_MIDDLE_CODE:
                                    fixed_y_pos_unit[i] <= fixed_y_pos_unit[i] + `ENEMY1_SPEED_MIDDLE;
                                SPEED_HIGH_CODE:
                                    fixed_y_pos_unit[i] <= fixed_y_pos_unit[i] + `ENEMY1_SPEED_HIGH;
                            endcase
                        end
                    end else begin
                        if(trigger && trigger_idx == i) begin
                            x_pos_unit[i]     <= 300;     // !SHOULD BE RANDOM
                            fixed_y_pos_unit[i] <= 0;
                            visible[i]        <= 1'b1;
                            speed_unit[i]     <= SPEED_LOW_CODE;
                        end else begin
                            fixed_y_pos_unit[i] <= fixed_y_pos_unit[i];
                        end
                    end
                end
            end

            always @(posedge clk_vga or posedge rst) begin
                if(rst) begin
                    bram_addr_unit[i] <= 0;
                end
            end

            assign rgb_alpha = visible[i]
                            && (req_x_addr_i >= x_pos_unit[i])
                            && (req_x_addr_i < x_pos_unit[i] + `ENEMY1_X_SIZE)
                            && (fixed_req_y_addr >= fixed_y_pos_unit[i])
                            && (fixed_req_y_addr < fixed_y_pos_unit[i] + `ENEMY1_Y_SIZE);
        end
    endgenerate
    assign rgb_alpha_o = rgb_alpha;

endmodule //enemy1