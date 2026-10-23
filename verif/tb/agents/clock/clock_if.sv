interface clock_if;

  logic clk;

  // usado pelo gerador de clock
  modport GEN (
    output clk
  );

  // usado pelo monitor
  modport MON (
    input clk
  );

endinterface : clock_if