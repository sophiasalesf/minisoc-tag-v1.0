interface reset_if;

  logic rst_n;

  // usado pelo driver
  modport DRV (
    output rst_n
  );

  // usado pelo monitor
  modport MON (
    input rst_n
  );

endinterface : reset_if