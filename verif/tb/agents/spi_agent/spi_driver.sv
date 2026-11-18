
class spi_driver extends uvm_driver #(spi_item);

  `uvm_component_utils(spi_driver)

  virtual spi_if vif;

  function new(string name = "spi_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    spi_item item;
    bit [39:0] frame;
    bit [39:0] miso_frame;

    // Estado inicial da interface SPI
    vif.sclk = 1'b0;
    vif.cs_n = 1'b1;
    vif.mosi = 1'b0;

    forever begin

      seq_item_port.get_next_item(item);

      frame = {item.rwb, item.addr, item.rsv, item.data};
      miso_frame = '0;

      // Seleciona o dispositivo
      vif.cs_n = 1'b0;

      // Transmite e recebe 40 bits, MSB primeiro
      for (int i = 39; i >= 0; i--) begin

        vif.mosi = frame[i];

        #50ns;
        vif.sclk = 1'b1;

        // Amostra MISO durante o nivel alto do SCLK
        #1ns;
        miso_frame[i] = vif.miso;

        #49ns;
        vif.sclk = 1'b0;

      end

      vif.cs_n = 1'b1;
      vif.mosi = 1'b0;

      // Armazena os 32 bits de dados recebidos
      item.read_data = miso_frame[31:0];

      #100ns;

      seq_item_port.item_done();

    end

  endtask

endclass : spi_driver
