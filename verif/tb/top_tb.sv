import uvm_pkg::*;
`include "uvm_macros.svh"

import clock_agent_pkg::*;
import reset_agent_pkg::*;
import minisoc_env_pkg::*;
import minisoc_tests_pkg::*;

module top_tb;

  clock_if clk_if();
  reset_if rst_if();
  spi_if spi_vif();

  memory_data_if mem_vif();

  minisoc_top dut (
    .clk (clk_if.clk),
    .rst_n (rst_if.rst_n),

    .spi_sclk (spi_vif.sclk),
    .spi_cs_n (spi_vif.cs_n),
    .spi_mosi (spi_vif.mosi),
    .spi_miso (spi_vif.miso),

    .mem_clk (mem_vif.clk),
    .mem_i_data (mem_vif.i_data),
    .mem_i_wr_en (mem_vif.wr_en),
    .mem_i_addr (mem_vif.addr),
    .mem_o_data (mem_vif.o_data)
  );

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

    uvm_config_db #(virtual spi_if)::set(
      null,
      "uvm_test_top.env.spi_agt",
      "vif",
      spi_vif
    );

    uvm_config_db #(virtual memory_data_if)::set(
      null,
      "uvm_test_top.env.mem_agt",
      "vif",
      mem_vif
    );

    run_test();

  end

  initial begin
    $dumpfile("minisoc_smoke.vcd");

    $dumpvars(0,
      clk_if.clk,
      rst_if.rst_n,
      spi_vif.sclk,
      spi_vif.cs_n,
      spi_vif.mosi,
      spi_vif.miso
    );
  end

endmodule : top_tb