
class spi_item extends uvm_sequence_item;

  `uvm_object_utils(spi_item)

  // Campos do frame SPI de 40 bits
  rand bit        rwb;
  rand bit [5:0]  addr;
  rand bit        rsv;
  rand bit [31:0] data;

  // Valor observado na linha MISO
  bit [31:0] read_data;

  // Quantidade de bits efetivamente transmitidos no frame
  // Um frame SPI completo possui 40 bits
  int unsigned nbits = 40;

  // Mantem o bit reservado em zero
  constraint c_rsv {
    rsv == 1'b0;
  }

  function new(string name = "spi_item");
    super.new(name);
  endfunction

endclass : spi_item
