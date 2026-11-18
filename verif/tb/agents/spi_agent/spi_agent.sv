
class spi_agent extends uvm_agent;

  `uvm_component_utils(spi_agent)

  virtual spi_if vif;

  spi_sequencer sequencer;
  spi_driver driver;
  spi_monitor monitor;

  function new(string name = "spi_agent",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Recupera a interface virtual SPI
    if (!uvm_config_db #(virtual spi_if)::get(this, "", "vif", vif))
      `uvm_fatal("SPI_AGENT", "spi_if nao encontrada")

    // Cria os componentes do agente
    sequencer = spi_sequencer::type_id::create("sequencer", this);
    driver = spi_driver::type_id::create("driver", this);
    monitor = spi_monitor::type_id::create("monitor", this);

    // Compartilha a interface com driver e monitor
    driver.vif = vif;
    monitor.vif = vif;

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Conecta driver ao sequencer
    driver.seq_item_port.connect(sequencer.seq_item_export);

  endfunction

endclass : spi_agent
