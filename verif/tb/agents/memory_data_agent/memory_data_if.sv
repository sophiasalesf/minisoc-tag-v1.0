interface memory_data_if;

  logic        clk;
  logic [31:0] i_data;
  logic        wr_en;
  logic [9:0]  addr;
  logic [31:0] o_data;

  // Sinais controlados pelo driver
  modport DRV (
    output clk,
    output i_data,
    output wr_en,
    output addr,
    input  o_data
  );

  // Sinais observados pelo monitor
  modport MON (
    input clk,
    input i_data,
    input wr_en,
    input addr,
    input o_data
  );

endinterface : memory_data_if