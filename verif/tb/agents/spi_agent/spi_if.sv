
interface spi_if;

  logic sclk;
  logic cs_n;
  logic mosi;
  logic miso;

  // Sinais controlados pelo driver SPI
  modport DRV (
    output sclk,
    output cs_n,
    output mosi,
    input  miso
  );

  // Sinais observados pelo monitor SPI
  modport MON (
    input sclk,
    input cs_n,
    input mosi,
    input miso
  );

endinterface : spi_if
