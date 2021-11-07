/*
 * Description  : produce 40MHz clock and game clock
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-02 14:19:22
 * LastEditTime : 2021-11-05 16:41:34
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\clk_mgr.v
 */
`include "../header/define.v"
module clk_mgr (
        input  wire clk,
        input  wire rst,
        output wire clk_vga,
        output reg  clk_run
    );

    // 40MHz
    clk_wiz_0 clk_wiz_0_dut(.clk_i(clk), .clk_40MHz(clk_vga));

    // 60Hz
    reg [`CNT_MAX_RUN_BIT_LEN-1:0] cnt_run;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            cnt_run <= 0;
            clk_run <= 0;
        end
        else begin
            if(cnt_run == `CNT_MAX_RUN - 1) begin
                cnt_run <= 0;
                clk_run <= ~clk_run;
            end
            else begin
                cnt_run <= cnt_run + 1;
            end
        end
    end

endmodule //clk_mgr
