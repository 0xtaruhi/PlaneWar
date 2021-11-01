/*
 * Description  : VGA driver
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 18:53:24
 * LastEditTime : 2021-11-01 23:17:32
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\dri_vga.v
 */

`include "../header/define.v"
module dri_vga (
        input  wire                     clk,
        input  wire                     en_i,

        output wire                     h_sync_o,          // 行同步信号
        output wire                     v_sync_o,          // 场同步信号
        output wire                     disp_o,         // 正在显示有效内容
        output wire [`H_DISP_LEN-1:0]   req_h_addr_o, // 请求获得的行地址（按照显示区域坐标）
        output wire [`V_DISP_LEN-1:0]   req_v_addr_o // 请求获得的列地址（按照显示区域坐标）
    );

    reg [`H_BIT_LEN-1:0] h_cnt;
    reg [`V_BIT_LEN-1:0] v_cnt;

    // 行场同步信号处理
    assign h_sync_o = ~(h_cnt < `H_SYNC);
    assign v_sync_o = ~(v_cnt < `V_SYNC);

    always @(posedge clk) begin
        if(en_i) begin
            if(h_cnt == `H_TOTAL - 1) begin
                h_cnt <= 0;
                if(v_cnt == `V_TOTAL - 1) begin
                    v_cnt <= 0;
                end
                else begin
                    v_cnt <= v_cnt + 1;
                end
            end
            else begin
                h_cnt <= h_cnt + 1;
            end
        end
        else begin
            h_cnt <= 0;
            v_cnt <= 0;
        end
    end


    assign disp_o = (h_cnt >= `H_START) && (h_cnt < `H_END)
           && (v_cnt >= `V_START) && (v_cnt < `V_END);
    assign req_h_addr_o = disp_o ? h_cnt - `H_START : 0;
    assign req_v_addr_o = disp_o ? v_cnt - `V_START : 0;


endmodule //dri_vga
