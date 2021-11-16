set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# vga pins
set_property PACKAGE_PIN P19 [get_ports h_sync_o]
set_property IOSTANDARD LVCMOS33 [get_ports h_sync_o]
set_property PACKAGE_PIN R19 [get_ports v_sync_o]
set_property IOSTANDARD LVCMOS33 [get_ports v_sync_o]
set_property PACKAGE_PIN G19 [get_ports {vga_r_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r_o[0]}]
set_property PACKAGE_PIN H19 [get_ports {vga_r_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r_o[1]}]
set_property PACKAGE_PIN J19 [get_ports {vga_r_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r_o[2]}]
set_property PACKAGE_PIN N19 [get_ports {vga_r_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r_o[3]}]
set_property PACKAGE_PIN J17 [get_ports {vga_g_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g_o[0]}]
set_property PACKAGE_PIN H17 [get_ports {vga_g_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g_o[1]}]
set_property PACKAGE_PIN G17 [get_ports {vga_g_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g_o[2]}]
set_property PACKAGE_PIN D17 [get_ports {vga_g_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g_o[3]}]
set_property PACKAGE_PIN N18 [get_ports {vga_b_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b_o[0]}]
set_property PACKAGE_PIN L18 [get_ports {vga_b_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b_o[1]}]
set_property PACKAGE_PIN K18 [get_ports {vga_b_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b_o[2]}]
set_property PACKAGE_PIN J18 [get_ports {vga_b_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b_o[3]}]

# push buttons
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN W19 [get_ports btn_l_pin_i]
set_property IOSTANDARD LVCMOS33 [get_ports btn_l_pin_i]
set_property PACKAGE_PIN T17 [get_ports btn_r_pin_i]
set_property IOSTANDARD LVCMOS33 [get_ports btn_r_pin_i]
set_property PACKAGE_PIN T18 [get_ports btn_u_pin_i]
set_property IOSTANDARD LVCMOS33 [get_ports btn_u_pin_i]
set_property PACKAGE_PIN U17 [get_ports btn_d_pin_i]
set_property IOSTANDARD LVCMOS33 [get_ports btn_d_pin_i]

# temp
set_property PACKAGE_PIN V17 [get_ports mode_i]
set_property IOSTANDARD LVCMOS33 [get_ports mode_i]


