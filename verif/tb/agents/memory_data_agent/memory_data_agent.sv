class memory_data_agent extends uvm_agent;

  `uvm_component_utils(memory_data_agent)

  virtual memory_data_if vif;

  memory_data_sequencer sequencer;
  memory_data_driver driver;
  memory_data_monitor monitor;

  function new(string name = "memory_data_agent",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual memory_data_if)::get(
          this, "", "vif", vif))
      `uvm_fatal("MEM_AGENT", "memory_data_if nao encontrada")

    sequencer = memory_data_sequencer::type_id::create(
      "sequencer", this);

    driver = memory_data_driver::type_id::create(
      "driver", this);

    monitor = memory_data_monitor::type_id::create(
      "monitor", this);

    driver.vif = vif;
    monitor.vif = vif;

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    driver.seq_item_port.connect(
      sequencer.seq_item_export);

  endfunction

endclass : memory_data_agent