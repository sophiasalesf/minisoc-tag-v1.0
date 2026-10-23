class clock_agent extends uvm_agent;

  `uvm_component_utils(clock_agent)

  virtual clock_if vif;

  clock_config cfg;
  clock_generator generator;
  clock_monitor monitor;

  function new(string name = "clock_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual clock_if)::get(this, "", "vif", vif))
      `uvm_fatal("CLOCK_AGENT", "clock_if nao encontrada")

    if (!uvm_config_db #(clock_config)::get(this, "", "cfg", cfg))
      cfg = clock_config::type_id::create("cfg");

    generator = clock_generator::type_id::create("generator", this);
    monitor = clock_monitor::type_id::create("monitor", this);

    generator.vif = vif;
    generator.cfg = cfg;

    monitor.vif = vif;
  endfunction

endclass : clock_agent