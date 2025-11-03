//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
//Date        : Mon Nov  3 17:17:29 2025
//Host        : pc129 running 64-bit Ubuntu 20.04.6 LTS
//Command     : generate_target pl_eth_10g_wrapper.bd
//Design      : pl_eth_10g_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module pl_eth_10g_wrapper
   (gt_ref_clk_clk_n,
    gt_ref_clk_clk_p,
    gt_rx_gt_port_0_n,
    gt_rx_gt_port_0_p,
    gt_tx_gt_port_0_n,
    gt_tx_gt_port_0_p,
    sfp_tx_dis);
  input gt_ref_clk_clk_n;
  input gt_ref_clk_clk_p;
  input gt_rx_gt_port_0_n;
  input gt_rx_gt_port_0_p;
  output gt_tx_gt_port_0_n;
  output gt_tx_gt_port_0_p;
  output [0:0]sfp_tx_dis;

  wire gt_ref_clk_clk_n;
  wire gt_ref_clk_clk_p;
  wire gt_rx_gt_port_0_n;
  wire gt_rx_gt_port_0_p;
  wire gt_tx_gt_port_0_n;
  wire gt_tx_gt_port_0_p;
  wire [0:0]sfp_tx_dis;

  pl_eth_10g pl_eth_10g_i
       (.gt_ref_clk_clk_n(gt_ref_clk_clk_n),
        .gt_ref_clk_clk_p(gt_ref_clk_clk_p),
        .gt_rx_gt_port_0_n(gt_rx_gt_port_0_n),
        .gt_rx_gt_port_0_p(gt_rx_gt_port_0_p),
        .gt_tx_gt_port_0_n(gt_tx_gt_port_0_n),
        .gt_tx_gt_port_0_p(gt_tx_gt_port_0_p),
        .sfp_tx_dis(sfp_tx_dis));
endmodule
