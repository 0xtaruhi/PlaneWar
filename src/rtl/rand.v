/*
 * Description  : random generator
 * Author       : Zhengyi Zhang
 * Date         : 2021-11-17 11:32:15
 * LastEditTime : 2021-11-17 12:48:43
 * LastEditors  : Zhengyi Zhang
 * FilePath     : \PlaneWar\src\rtl\rand.v
 */
`include "../header/define.v"
module rand (
    input  wire clk_vga,
    input  wire rst,
    
    output reg  [`RAND_WIDTH-1:0] data_o
);

    wire [`RAND_WIDTH-1:0] seed;
    assign seed = `RAND_SEED;
    
    genvar i;
    generate
        for(i=0; i<`RAND_WIDTH; i=i+1) begin:RAND_LOOP
            always @(posedge clk_vga or posedge rst) begin
                if(rst) begin
                    data_o[i] <= seed[i];
                end else begin
                    case(i)
                        0:begin
                            data_o[i] <= data_o[`RAND_WIDTH-1];
                        end
                        1, 2, 3, 5:begin
                            data_o[i] <= data_o[i] ^ data_o[`RAND_WIDTH-1];
                        end
                        default: begin
                            data_o[i] <= data_o[i-1];
                        end
                    endcase
                end
            end
        end
    endgenerate

endmodule //rand