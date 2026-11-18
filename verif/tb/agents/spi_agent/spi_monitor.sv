
class spi_monitor extends uvm_monitor;

  `uvm_component_utils(spi_monitor)

  virtual spi_if vif;

  uvm_analysis_port #(spi_item) ap;

  function new(string name = "spi_monitor",
               uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);

    bit [39:0] mosi_frame;
    bit [39:0] miso_frame;
    spi_item item;

    forever begin

      // Aguarda o inicio de uma transacao SPI
      @(negedge vif.cs_n);

      mosi_frame = '0;
      miso_frame = '0;

      // Observa os 40 bits transmitidos e recebidos
      for (int i = 39; i >= 0; i--) begin

        @(posedge vif.sclk);

        // Captura MOSI na borda de subida
        mosi_frame[i] = vif.mosi;

        // Captura MISO durante a fase alta do clock
        #1ns;
        miso_frame[i] = vif.miso;

      end

      // Aguarda o encerramento do frame
      @(posedge vif.cs_n);

      // Reconstrói os campos observados
      item = spi_item::type_id::create("item");

      item.rwb  = mosi_frame[39];
      item.addr = mosi_frame[38:33];
      item.rsv  = mosi_frame[32];
      item.data = mosi_frame[31:0];

      // Guarda o dado recebido pela linha MISO
      item.read_data = miso_frame[31:0];

      // Publica a transacao observada
      ap.write(item);

    end

  endtask

endclass : spi_monitor
