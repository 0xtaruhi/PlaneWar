/*
 * Description  : 
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-23 17:13:45
 * LastEditTime : 2021-11-23 20:03:52
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\info.v
 */

`include "../header/define.v"
module info (
    input  wire                        clk_vga,
    // input  wire                        clk_run,
    input  wire                        rst,
    input  wire [     `H_DISP_LEN-1:0] req_x_addr_i,
    input  wire [     `V_DISP_LEN-1:0] req_y_addr_i,
    input  wire                        v_sync_i,
    input  wire [`SCORE_WIDTH_DEC-1:0] score_i,     //decimal
    input  wire [                 1:0] score_digit_i,

    output wire                        vga_alpha_o
);

    wire [`NUMBER_BRAM_DEPTH_BIT_LEN-1:0] bram_addr_number;
    reg  [`NUMBER_BRAM_DEPTH_BIT_LEN-1:0] bram_addr_score_unit [`SHOW_SCORE_DIGIT-1:0];
    wire                                  bram_info_number;
    wire [`NUMBER_BRAM_DEPTH_BIT_LEN-1:0] num_addr_offset [9:0];
    wire [         `NUM_SIZE_BIT_LEN-1:0] num_x_size [9:0];
    wire [         `NUM_SIZE_BIT_LEN-1:0] num_y_size [9:0];
    wire [               `H_DISP_LEN-1:0] score_x_pos_beg_unit [`SHOW_SCORE_DIGIT-1:0];
    wire [               `H_DISP_LEN-1:0] score_x_pos_end_unit [`SHOW_SCORE_DIGIT-1:0];
    wire [               `V_DISP_LEN-1:0] score_y_pos_end_unit [`SHOW_SCORE_DIGIT-1:0];
    wire [         `SHOW_SCORE_DIGIT-1:0] in_req_area;
    reg  [         `SHOW_SCORE_DIGIT-1:0] digit_vali;
    wor  [                           2:0] curr_digit;
    reg  [                           3:0] disp_digit_value     [`SHOW_SCORE_DIGIT-1:0];
    wire                                  displaying_score;

    
    bram_number bram_number
    (
        .clka(clk_vga),
        .ena(1'b1),
        .addra(bram_addr_number),
        .douta(bram_info_number)
    );

    genvar i;
    generate
        for(i=0;i<`SHOW_SCORE_DIGIT;i=i+1) begin: score_loop

            assign score_x_pos_beg_unit[i] = i > 0 ? score_x_pos_end_unit[i-1] + `SCORE_DISP_GAP : `SCORE_DISP_X_POS;
            assign score_x_pos_end_unit[i] = score_x_pos_beg_unit[i] + num_x_size[disp_digit_value[i]];
            assign score_y_pos_end_unit[i] = `SCORE_DISP_Y_POS + num_y_size[disp_digit_value[i]];

            assign in_req_area [i] = (req_x_addr_i >= score_x_pos_beg_unit[i])
                                    && (req_x_addr_i < score_x_pos_end_unit[i])
                                    && (req_y_addr_i >= `SCORE_DISP_Y_POS)
                                    && (req_y_addr_i < score_y_pos_end_unit[i])
                                    && digit_vali[i];

            assign curr_digit = in_req_area [i] ? i : 0;
            
            always @(posedge clk_vga) begin
                if(rst) begin
                    bram_addr_score_unit[i] <= 0;
                end else begin
                    if(~v_sync_i) begin
                        bram_addr_score_unit[i] <= num_addr_offset[disp_digit_value[i]];
                    end else begin
                        if(in_req_area[i]) begin
                            bram_addr_score_unit[i] <= bram_addr_score_unit[i] + 1;
                        end else begin
                            bram_addr_score_unit[i] <= bram_addr_score_unit[i];
                        end
                    end
                end
            end
        end
    endgenerate


    assign displaying_score = |in_req_area;
    assign bram_addr_number = bram_addr_score_unit[curr_digit];
    assign vga_alpha_o = displaying_score ? bram_info_number : 0;

    // assign score_x_pos_beg_unit[0] = `SCORE_DISP_X_POS;
    // assign score_x_pos_beg_unit[0] = `SCORE_

    always @(*) begin
        case(score_digit_i)
            2'b00: begin
                digit_vali = `SHOW_SCORE_DIGIT'b1;
                disp_digit_value[0] = 0;
                disp_digit_value[1] = 0;
                disp_digit_value[2] = 0;
            end
            2'b01: begin
                digit_vali = `SHOW_SCORE_DIGIT'b111;
                disp_digit_value[0] = score_i[3:0];
                disp_digit_value[1] = 0;
                disp_digit_value[2] = 0;
            end
            2'b10: begin 
                digit_vali = `SHOW_SCORE_DIGIT'b1111;
                disp_digit_value[0] = score_i[7:4];
                disp_digit_value[1] = score_i[3:0];
                disp_digit_value[2] = 0;
            end
            2'b11: begin
                digit_vali = `SHOW_SCORE_DIGIT'b11111;
                disp_digit_value[0] = score_i[11:8];
                disp_digit_value[1] = score_i[7:4];
                disp_digit_value[2] = score_i[3:0];
            end
            default: begin 
                digit_vali = 0;
                disp_digit_value[0] = 0;
                disp_digit_value[1] = 0;
                disp_digit_value[2] = 0;
            end
        endcase
        disp_digit_value[3] = 0;
        disp_digit_value[4] = 0;
    end


    assign num_addr_offset[0] = `NUM_0_OFFSET;
    assign num_addr_offset[1] = `NUM_1_OFFSET;
    assign num_addr_offset[2] = `NUM_2_OFFSET;
    assign num_addr_offset[3] = `NUM_3_OFFSET;
    assign num_addr_offset[4] = `NUM_4_OFFSET;
    assign num_addr_offset[5] = `NUM_5_OFFSET;
    assign num_addr_offset[6] = `NUM_6_OFFSET;
    assign num_addr_offset[7] = `NUM_7_OFFSET;
    assign num_addr_offset[8] = `NUM_8_OFFSET;
    assign num_addr_offset[9] = `NUM_9_OFFSET;
    assign num_x_size[0] = `NUM_0_WIDTH;
    assign num_x_size[1] = `NUM_1_WIDTH;
    assign num_x_size[2] = `NUM_2_WIDTH;
    assign num_x_size[3] = `NUM_3_WIDTH;
    assign num_x_size[4] = `NUM_4_WIDTH;
    assign num_x_size[5] = `NUM_5_WIDTH;
    assign num_x_size[6] = `NUM_6_WIDTH;
    assign num_x_size[7] = `NUM_7_WIDTH;
    assign num_x_size[8] = `NUM_8_WIDTH;
    assign num_x_size[9] = `NUM_9_WIDTH;
    assign num_y_size[0] = `NUM_0_HEIGHT;
    assign num_y_size[1] = `NUM_1_HEIGHT;
    assign num_y_size[2] = `NUM_2_HEIGHT;
    assign num_y_size[3] = `NUM_3_HEIGHT;
    assign num_y_size[4] = `NUM_4_HEIGHT;
    assign num_y_size[5] = `NUM_5_HEIGHT;
    assign num_y_size[6] = `NUM_6_HEIGHT;
    assign num_y_size[7] = `NUM_7_HEIGHT;
    assign num_y_size[8] = `NUM_8_HEIGHT;
    assign num_y_size[9] = `NUM_9_HEIGHT;

endmodule //info