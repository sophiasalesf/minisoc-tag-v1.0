
class spi_read_sequence extends uvm_sequence #(spi_item);

  `uvm_object_utils(spi_read_sequence)

  bit [5:0]  read_addr = 6'h00;
  bit [31:0] received_data;

  function new(string name = "spi_read_sequence");
    super.new(name);
  endfunction

  task body();

    spi_item request_item;
    spi_item response_item;

    // Frame A: solicita a leitura do registrador
    request_item = spi_item::type_id::create("request_item");

    start_item(request_item);

    if (!request_item.randomize() with {
      rwb  == 1'b1;
      addr == local::read_addr;
      rsv  == 1'b0;
      data == 32'h00000000;
    })
      `uvm_fatal("SPI_READ_SEQ", "Falha ao randomizar request_item")

    finish_item(request_item);

    // Frame B: fornece clocks para receber a resposta
    response_item = spi_item::type_id::create("response_item");

    start_item(response_item);

    if (!response_item.randomize() with {
      rwb  == 1'b1;
      addr == 6'h3F;
      rsv  == 1'b0;
      data == 32'h00000000;
    })
      `uvm_fatal("SPI_READ_SEQ", "Falha ao randomizar response_item")

    finish_item(response_item);

    // O driver preenche read_data antes de finalizar o item
    received_data = response_item.read_data;

    `uvm_info("SPI_READ_SEQ",
              $sformatf("Dado recebido por SPI: 0x%08h", received_data),
              UVM_LOW)

  endtask

endclass : spi_read_sequence
