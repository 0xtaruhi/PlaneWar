/*
 * Description  : 
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-19 09:52:13
 * LastEditTime : 2021-11-19 21:50:43
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\enemy_base.v
 */
`include "../header/define.v"
module enemy_base#(
        parameter MAX_ENEMY_NUM = 10,
        parameter MAX_ENEMY_NUM_BIT_LEN = 4,
        parameter SPEED         = `ENEMY_SPEED_LOW,
        parameter TRIGGER_FREQ  = 5,
        parameter ENEMY_X_SIZE  = 100,
        parameter ENEMY_Y_SIZE  = 100,
        parameter RAND_POS_BIT_LEN = 9,
        parameter RAND_OFFSET   = 0,
        parameter BRAM_WIDTH    = 20,
        parameter BRAM_DEPTH    = 10000,
        parameter BRAM_DEPTH_BIT_LEN = 16
    )
    (
        input  wire                          clk_vga,
        input  wire                          clk_run,
        input  wire                          rst,
        input  wire                          en_i,
        input  wire                          v_sync_i,
        input  wire [       `H_DISP_LEN-1:0] req_x_addr_i,
        input  wire [       `V_DISP_LEN-1:0] req_y_addr_i,
        input  wire [     MAX_ENEMY_NUM-1:0] disappear_i,         // HIGH when the craft becomes unvisiable
        input  wire [       `RAND_WIDTH-1:0] rand_pos_i,

        output wire [BRAM_DEPTH_BIT_LEN-1:0] bram_addr_o,
        output wire                          enemy_vali_o,
        output wire [MAX_ENEMY_NUM_BIT_LEN-1:0] curr_enemy_idx_o,
        output wire                          trigger_o,
        output wire [MAX_ENEMY_NUM_BIT_LEN-1:0] trigger_idx_o
    );
    // local parameters
    localparam ENEMY_CNT_MAX_TRIGGER = `FREQ_RUN / TRIGGER_FREQ;
    localparam ENEMY_CNT_MAX_TRIGGER_BIT_LEN = funclog2(ENEMY_CNT_MAX_TRIGGER);
    // registers
    reg  [           `OBJ_X_POS_BIT_LEN-1:0] x_pos_unit       [MAX_ENEMY_NUM-1:0];
    /* when the enemy is at the top of the screen, it need to be showed partly,
       to make the postion always be positive, there are two kinds of y-position.
       fixed_y_pos = real_y_pos + ENEMY_Y_SIZE
    */
    reg  [           `OBJ_Y_POS_BIT_LEN-1:0] fixed_y_pos_unit [MAX_ENEMY_NUM-1:0];
    wire [                      `V_DISP-1:0] fixed_req_y_addr;
    // displocked_fixed_y_pos_unit ensures that in a frame(displaying) it will not be changed!
    // and displocked_fixed_y_pos_unit should be used in always block which is triggered by vga clk.
    reg  [           `OBJ_Y_POS_BIT_LEN-1:0] displocked_fixed_y_pos_unit [MAX_ENEMY_NUM-1:0];
    reg  [        MAX_ENEMY_NUM_BIT_LEN-1:0] trigger_idx;
    reg                                      trigger;
    reg                                      visible          [MAX_ENEMY_NUM-1:0];
    reg  [ENEMY_CNT_MAX_TRIGGER_BIT_LEN-1:0] cnt_trigger;
    wor  [        MAX_ENEMY_NUM_BIT_LEN-1:0] curr_enemy_idx;
    wire [           BRAM_DEPTH_BIT_LEN-1:0] bram_addr;
    reg  [           BRAM_DEPTH_BIT_LEN-1:0] bram_addr_unit   [MAX_ENEMY_NUM-1:0];
    wire                                     in_req_area      [MAX_ENEMY_NUM-1:0];
    wor                                      enemy_vali;        // current pixel has a enemy object

    assign fixed_req_y_addr = req_y_addr_i + ENEMY_Y_SIZE; // see line:44
    assign trigger_o        = trigger;
    assign trigger_idx_o    = trigger_idx;
    assign curr_enemy_idx_o = curr_enemy_idx;

    always @(posedge clk_run or posedge rst)begin
        if(rst) begin
            cnt_trigger <= 0;
            trigger_idx <= 0;
            trigger     <= 0;
        end else begin
            if(cnt_trigger == ENEMY_CNT_MAX_TRIGGER - 1)begin
                cnt_trigger <= 0;
                trigger     <= 1;
                if(trigger_idx == MAX_ENEMY_NUM - 1) begin
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
        for(i=0;i<MAX_ENEMY_NUM;i=i+1) begin: ENEMY_LOOP

            // displocked_fixed_y_pos_unit
            always @(posedge clk_vga or posedge rst)begin
                if(rst) begin
                    displocked_fixed_y_pos_unit[i] <= 0;
                end else begin
                    if(~v_sync_i) begin
                        displocked_fixed_y_pos_unit[i] <= fixed_y_pos_unit[i];
                    end else if(trigger && trigger_idx == i) begin
                        displocked_fixed_y_pos_unit[i] <= 0;
                    end else begin
                        displocked_fixed_y_pos_unit[i] <= displocked_fixed_y_pos_unit[i];
                    end
                end
            end

            always @(posedge clk_run or posedge rst)begin
                if(rst) begin
                    x_pos_unit[i]       <= 0;
                    fixed_y_pos_unit[i] <= 0;
                    visible[i]          <= 0;
                end else begin
                    if(visible[i]) begin
                        if(disappear_i[i] || fixed_y_pos_unit[i] >= `V_DISP + ENEMY_Y_SIZE) begin
                            visible[i] <= 0;
                            fixed_y_pos_unit[i] <= 0;
                        end else begin
                            visible[i] <= visible[i];
                            fixed_y_pos_unit[i] <= fixed_y_pos_unit[i] + SPEED;
                        end
                    end else begin
                        if(trigger && trigger_idx == i) begin
                            x_pos_unit[i] <= rand_pos_i[RAND_OFFSET+:RAND_POS_BIT_LEN];
                            fixed_y_pos_unit[i] <= 0;
                            visible[i] <= 1;
                        end else begin
                            fixed_y_pos_unit[i] <= fixed_y_pos_unit[i];
                        end
                    end
                end
            end

            //bram address
            always @(posedge clk_vga or posedge rst) begin
                if(rst) begin
                    bram_addr_unit[i] <= 0;
                end else begin
                    if(~v_sync_i) begin
                        if(displocked_fixed_y_pos_unit[i] < ENEMY_Y_SIZE) begin
                            bram_addr_unit[i] <= (ENEMY_Y_SIZE - displocked_fixed_y_pos_unit[i]) * ENEMY_X_SIZE;
                        end else begin
                            bram_addr_unit[i] <= 0;
                        end
                    end else begin
                        if(in_req_area[i]) begin
                            bram_addr_unit[i] <= bram_addr_unit[i] + 1;
                        end else begin
                            bram_addr_unit[i] <= bram_addr_unit[i];
                        end
                    end
                end
            end

            assign in_req_area[i] = visible[i]
                            && (req_x_addr_i >= x_pos_unit[i])
                            && (req_x_addr_i < x_pos_unit[i] + ENEMY_X_SIZE)
                            && (fixed_req_y_addr >= displocked_fixed_y_pos_unit[i])
                            && (fixed_req_y_addr < displocked_fixed_y_pos_unit[i] + ENEMY_Y_SIZE);

            assign curr_enemy_idx = in_req_area[i] ? i : 0;
            assign enemy_vali = in_req_area[i];
        end
    endgenerate

    assign enemy_vali_o = enemy_vali;
    assign bram_addr = bram_addr_unit[curr_enemy_idx];
    assign bram_addr_o = bram_addr;

    // function
    function integer funclog2;
        input integer value;
        begin
            value = value - 1;
            for (funclog2=0; value>0; funclog2=funclog2+1)
                value = value >> 1;
        end
    endfunction
endmodule //enemy_base
