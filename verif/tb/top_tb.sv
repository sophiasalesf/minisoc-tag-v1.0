import uvm_pkg::*;
`include "uvm_macros.svh"

import clock_agent_pkg::*;
import reset_agent_pkg::*;
import minisoc_env_pkg::*;
import minisoc_tests_pkg::*;

module top_tb;

  clock_if clk_if();
  reset_if rst_if();

  logic spi_sclk;
  logic spi_cs_n;
  logic spi_mosi;
  logic spi_miso;

  logic mem_clk;
  logic [31:0] mem_i_data;
  logic mem_i_wr_en;
  logic [9:0] mem_i_addr;
  logic [31:0] mem_o_data;

  minisoc_top dut (
    .clk (clk_if.clk),
    .rst_n (rst_if.rst_n),

    .spi_sclk (spi_sclk),
    .spi_cs_n (spi_cs_n),
    .spi_mosi (spi_mosi),
    .spi_miso (spi_miso),

    .mem_clk (mem_clk),
    .mem_i_data (mem_i_data),
    .mem_i_wr_en (mem_i_wr_en),
    .mem_i_addr (mem_i_addr),
    .mem_o_data (mem_o_data)
  );

  initial begin
    spi_sclk    = 1'b0;
    spi_cs_n    = 1'b1;
    spi_mosi    = 1'b0;

    mem_clk     = 1'b0;
    mem_i_data  = 32'b0;
    mem_i_wr_en = 1'b0;
    mem_i_addr  = 10'b0;
  end

  initial begin

    uvm_config_db #(virtual clock_if)::set(
      null,
      "uvm_test_top.env.clk_agent",
      "vif",
      clk_if
    );

    uvm_config_db #(virtual reset_if)::set(
      null,
      "uvm_test_top.env.rst_agent",
      "vif",
      rst_if
    );

    run_test();

  end

  initial begin
    $dumpfile("minisoc_smoke.vcd");
    $dumpvars(0, clk_if.clk, rst_if.rst_n);
  end

endmodule : top_tb