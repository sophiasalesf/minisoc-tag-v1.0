
class spi_sequence extends uvm_sequence #(spi_item);

  `uvm_object_utils(spi_sequence)

  function new(string name = "spi_sequence");
    super.new(name);
  endfunction

  task body();

    spi_item item;

    item = spi_item::type_id::create("item");

    start_item(item);

    // Primeira transacao: escrita no registrador KEY0
    if (!item.randomize() with {
      rwb  == 1'b0;
      addr == 6'h00;
      rsv  == 1'b0;
      data == 32'h12345678;
    })
      `uvm_fatal("SPI_SEQ", "Falha ao randomizar spi_item")

    finish_item(item);

  endtask

endclass : spi_sequence
