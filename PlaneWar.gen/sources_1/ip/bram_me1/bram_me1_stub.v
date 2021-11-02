// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Tue Nov  2 20:45:51 2021
// Host        : MagicBook-ZhangZhengyi running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/fpga/project/PlaneWar/PlaneWar.gen/sources_1/ip/bram_me1/bram_me1_stub.v
// Design      : bram_me1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2020.2" *)
module bram_me1(clka, ena, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,addra[13:0],douta[4:0]" */;
  input clka;
  input ena;
  input [13:0]addra;
  output [4:0]douta;
endmodule
