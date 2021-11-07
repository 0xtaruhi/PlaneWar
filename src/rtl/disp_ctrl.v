/*
 * Description  : display controller
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 23:00:26
 * LastEditTime : 2021-11-07 11:44:17
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\disp_ctrl.v
 */
`include "../header/define.v"

module disp_ctrl (
        input  wire                         clk_vga,
        input  wire                         clk_run,
        input  wire                         rst,

        input  wire  [`COLOR_RGB_DEPTH-1:0] me_rgb_i,
        input  wire                         me_alpha_i,
        input  wire  [`COLOR_RGB_DEPTH-1:0] bullet_rgb_i,
        input  wire                         bullet_alpha_i,

        output wire  [     `H_DISP_LEN-1:0] req_x_addr_o,
        output wire  [     `V_DISP_LEN-1:0] req_y_addr_o,
        output wire  [  `COLOR_R_DEPTH-1:0] vga_r_o,
        output wire  [  `COLOR_G_DEPTH-1:0] vga_g_o,
        output wire  [  `COLOR_B_DEPTH-1:0] vga_b_o,
        output wire                         h_sync_o,
        output wire                         v_sync_o,
        output wire                         disp_o            // 正在显示有效内容
    );

    reg  [`COLOR_RGB_DEPTH-1:0] vga_rgb;
    assign {vga_r_o, vga_g_o, vga_b_o} = vga_rgb;

    dri_vga dri_vga_dut(
                .clk(clk_vga),
                .rst(rst),
                .en_i(1'b1),
                .h_sync_o(h_sync_o),
                .v_sync_o(v_sync_o),
                .disp_o(disp_o),
                .req_x_addr_o(req_x_addr_o),
                .req_y_addr_o(req_y_addr_o)
            );

    always @(posedge clk_vga or posedge rst) begin
        if(rst) begin
            vga_rgb <= 12'b0;
        end
        else begin
            if(disp_o) begin
                if(bullet_alpha_i) begin
                    vga_rgb <= bullet_rgb_i;
                end
                else if(me_alpha_i) begin
//                if(me_alpha_i) begin
                    vga_rgb <= me_rgb_i;
                end
                else begin
                    vga_rgb <= {`BG_COLOR_R, `BG_COLOR_G, `BG_COLOR_B};
                end
            end
            else begin
                vga_rgb <= 12'b0;
            end
        end
    end
endmodule //disp_ctrl
