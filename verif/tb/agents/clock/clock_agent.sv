
class clock_agent extends uvm_agent;

  `uvm_component_utils(clock_agent)

  virtual clock_if vif;

  clock_sequencer sequencer;
  clock_driver driver;
  clock_monitor monitor;

  function new(string name = "clock_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual clock_if)::get(this, "", "vif", vif))
      `uvm_fatal("CLOCK_AGENT", "clock_if nao encontrada")

    sequencer = clock_sequencer::type_id::create("sequencer", this);
    driver = clock_driver::type_id::create("driver", this);
    monitor = clock_monitor::type_id::create("monitor", this);

    driver.vif = vif;
    monitor.vif = vif;
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass : clock_agent