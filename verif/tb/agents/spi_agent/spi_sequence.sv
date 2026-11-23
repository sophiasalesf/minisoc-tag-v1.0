class spi_sequence extends uvm_sequence #(spi_item);

  `uvm_object_utils(spi_sequence)

  // Valores configuraveis pela virtual sequence
  bit [5:0]  write_addr = 6'h00;
  bit [31:0] write_data = 32'h12345678;

  function new(string name = "spi_sequence");
    super.new(name);
  endfunction

  task body();

    spi_item item;

    item = spi_item::type_id::create("item");

    start_item(item);

    // Escrita SPI com endereco e dado configuraveis
    if (!item.randomize() with {
      rwb  == 1'b0;
      addr == local::write_addr;
      rsv  == 1'b0;
      data == local::write_data;
    })
      `uvm_fatal("SPI_SEQ", "Falha ao randomizar spi_item")

    finish_item(item);

  endtask

endclass : spi_sequence
