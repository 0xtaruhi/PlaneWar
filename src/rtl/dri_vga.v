/*
 * Description  : VGA driver
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 18:53:24
 * LastEditTime : 2021-11-03 19:32:04
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\dri_vga.v
 */

`include "../header/define.v"
module dri_vga (
        input  wire                     clk,
        input  wire                     rst,
        input  wire                     en_i,

        output wire                     h_sync_o,          // 行同步信�?
        output wire                     v_sync_o,          // 场同步信�?
        output wire                     disp_o,            // 正在显示有效内容
//        output wire                     req_o,             // 请求地址有效
        output wire [`H_DISP_LEN-1:0]   req_x_addr_o,      // 请求获得的行地址（按照显示区域坐标）
        output wire [`V_DISP_LEN-1:0]   req_y_addr_o       // 请求获得的列地址（按照显示区域坐标）
    );

    reg [`H_BIT_LEN-1:0] h_cnt;
    reg [`V_BIT_LEN-1:0] v_cnt;

    initial begin
        h_cnt = 0;
        v_cnt = 0;
    end

    // 行场同步信号处理
    assign h_sync_o = ~(h_cnt < `H_SYNC);
    assign v_sync_o = ~(v_cnt < `V_SYNC);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end
        else begin
            if(en_i) begin
                if(h_cnt == `H_TOTAL - 1'b1) begin
                    h_cnt <= 0;
                    if(v_cnt == `V_TOTAL - 1'b1) begin
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
    end


    assign disp_o = (h_cnt >= `H_START) && (h_cnt < `H_END)
           && (v_cnt >= `V_START) && (v_cnt < `V_END);

    // 考虑BRAM延迟的地�??请求信号
    wire [`H_DISP_LEN-1:0] req_x_addr;
    wire [`V_DISP_LEN-1:0] req_y_addr;
    wire                   req;
    assign req_x_addr = h_cnt + `ROM_READ_DELAY - `H_START;
    assign req_y_addr = v_cnt - `V_START;
    assign req = (req_x_addr >= 0) && (req_y_addr < `H_DISP);
    assign req_x_addr_o = req ? req_x_addr : 0;
    assign req_y_addr_o = req ? req_y_addr : 0;

endmodule //dri_vga
