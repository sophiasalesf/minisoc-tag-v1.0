class reset_agent extends uvm_agent;

  `uvm_component_utils(reset_agent)

  virtual reset_if vif;

  reset_sequencer sequencer;
  reset_driver driver;
  reset_monitor monitor;

  function new(string name = "reset_agent",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual reset_if)::get(this, "", "vif", vif))
      `uvm_fatal("RESET_AGENT", "reset_if nao encontrada")

    sequencer = reset_sequencer::type_id::create("sequencer", this);
    driver = reset_driver::type_id::create("driver", this);
    monitor = reset_monitor::type_id::create("monitor", this);

    driver.vif = vif;
    monitor.vif = vif;
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass : reset_agent