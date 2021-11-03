/*
 * Description  : produce 40MHz clock and game clock
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-02 14:19:22
 * LastEditTime : 2021-11-02 14:48:41
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\clk_mgr.v
 */
`include "../header/define.v"
module clk_mgr (
        input  wire clk,
        input  wire rst,
        output wire clk_40MHz,
        output reg  clk_60Hz
    );

    // 40MHz
    clk_wiz_0 clk_wiz_0_dut(.clk_i(clk), .clk_40MHz(clk_40MHz));

    // 60Hz
    reg [`CNT_MAX_RUN_BIT_LEN-1:0] cnt_60Hz;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            cnt_60Hz <= 0;
        end
        else begin
            if(cnt_60Hz == `CNT_MAX_RUN - 1) begin
                cnt_60Hz <= 0;
                clk_60Hz <= ~clk_60Hz;
            end
            else begin
                cnt_60Hz <= cnt_60Hz + 1;
            end
        end
    end

endmodule //clk_mgr
