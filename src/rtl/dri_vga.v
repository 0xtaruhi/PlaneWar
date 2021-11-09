/*
 * Description  : VGA driver
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-01 18:53:24
 * LastEditTime : 2021-11-09 14:59:28
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\dri_vga.v
 */

`include "../header/define.v"
module dri_vga (
        input  wire                     clk,
        input  wire                     rst,
        input  wire                     en_i,

        output wire                     h_sync_o,
        output wire                     v_sync_o,
        output wire                     disp_o,
        output wire [`H_DISP_LEN-1:0]   req_x_addr_o,
        output wire [`V_DISP_LEN-1:0]   req_y_addr_o
    );

    reg  [ `H_BIT_LEN-1:0] h_cnt;
    reg  [ `V_BIT_LEN-1:0] v_cnt;
    wire [`H_DISP_LEN-1:0] req_x_addr;
    wire [`V_DISP_LEN-1:0] req_y_addr;
    wire                   req;

    initial begin
        h_cnt = 0;
        v_cnt = 0;
    end

    // H V syncronization signal
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

    // display output signal
    assign disp_o = (h_cnt >= `H_START) && (h_cnt < `H_END)
           && (v_cnt >= `V_START) && (v_cnt < `V_END);

    // the bram has 2 cycles delay
    assign req_x_addr = h_cnt + `ROM_READ_DELAY - `H_START;
    assign req_y_addr = v_cnt - `V_START;
    assign req = (req_x_addr >= 0) && (req_y_addr < `H_DISP);
    assign req_x_addr_o = req ? req_x_addr : 0;
    assign req_y_addr_o = req ? req_y_addr : 0;

endmodule //dri_vga
