/*
 * Description  : 
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 23:00:26
 * LastEditTime : 2021-11-02 14:35:59
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\disp_controller.v
 */
`include "../header/define.v"

module disp_controller (
    input  wire clk,
    input  wire rst,

    output wire  [`COLOR_R_DEPTH-1:0] vga_r_o,
    output wire  [`COLOR_G_DEPTH-1:0] vga_g_o,
    output wire  [`COLOR_B_DEPTH-1:0] vga_b_o,
    output wire                       h_sync_o,
    output wire                      v_sync_o
);

    wire [`H_DISP_LEN-1:0] req_h_addr;
    wire [`V_DISP_LEN-1:0] req_v_addr;
    wire disp;                          // 正在显示有效内容
    reg  [           11:0] vga_rgb;
    assign {vga_r_o, vga_g_o, vga_b_o} = vga_rgb;

    dri_vga dri_vga_dut(
        .clk(clk),
        .rst(rst),
        .en_i(1'b1),
        .h_sync_o(h_sync_o),
        .v_sync_o(v_sync_o),
        .disp_o(disp),
        .req_h_addr_o(req_h_addr),
        .req_v_addr_o(req_v_addr)
    );

    always @(*) begin
       vga_rgb = {req_h_addr, 2'b00};
    end

endmodule //disp_controller