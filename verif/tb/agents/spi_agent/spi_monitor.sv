
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
    int unsigned bit_count;
    spi_item item;

    forever begin

      // Aguarda o inicio de uma transacao SPI
      @(negedge vif.cs_n);

      mosi_frame = '0;
      miso_frame = '0;
      bit_count = 0;

      // Observa os bits ate CS_n ser liberado
      forever begin

        @(posedge vif.sclk or posedge vif.cs_n);

        // CS_n alto encerra o frame, completo ou nao
        if (vif.cs_n === 1'b1)
          break;

        if (bit_count < 40) begin

          // Captura MOSI na borda de subida
          mosi_frame[39 - bit_count] = vif.mosi;

          // Captura MISO durante o nivel alto
          #1ns;
          miso_frame[39 - bit_count] = vif.miso;

          bit_count++;

        end
        else begin
          `uvm_error("SPI_MON", "Frame SPI excedeu 40 bits")
        end

      end

      // Cria um item com a quantidade observada de bits
      item = spi_item::type_id::create("item");

      item.nbits = bit_count;
      item.rwb = mosi_frame[39];
      item.addr = mosi_frame[38:33];
      item.rsv = mosi_frame[32];
      item.data = mosi_frame[31:0];

      if (bit_count == 40)
        item.read_data = miso_frame[31:0];
      else
        item.read_data = 32'b0;

      // Publica o frame observado para o checker
      ap.write(item);

      if (bit_count < 40)
        `uvm_info("SPI_MON", $sformatf("Frame SPI interrompido apos %0d bits", bit_count), UVM_LOW)

    end

  endtask

endclass : spi_monitor
