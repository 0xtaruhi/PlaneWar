/*
 * Description  : to delay n clk cycles 
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-03 00:01:28
 * LastEditTime : 2021-11-15 23:20:15
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\dff_delay.v
 */
module dff_delay #(
        DELAY=2,
        DATA_WIDTH=1
    ) (
        input wire                  clk,
        input wire                  rst,
        input wire                  en_i,
        input wire [DATA_WIDTH-1:0] data_i,

        output reg [DATA_WIDTH-1:0] data_o
    );
    reg [DATA_WIDTH-1:0] data_reg [DELAY-1:0];
    genvar i;

    generate
        for(i=1;i<DELAY;i=i+1) begin:DFF_LOOP
            always @(posedge clk or posedge rst) begin
                if(rst) begin
                    data_reg[i] <= 0;
                end
                else if(en_i) begin
                    data_reg[i] <= data_reg[i-1];
                end
                else begin
                    data_reg[i] <= 0;
                end
            end
        end
    endgenerate

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            data_reg[0] <= 0;
            data_o <= 0;
        end
        else if(en_i) begin
            data_reg[0] <= data_i;
            data_o <= data_reg[DELAY-1];
        end
        else begin
            data_reg[0] <= 0;
            data_o <= 0;
        end
    end

endmodule
