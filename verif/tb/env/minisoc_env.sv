
class minisoc_env extends uvm_env;

  `uvm_component_utils(minisoc_env)

  clock_agent clk_agent;
  reset_agent rst_agent;

  minisoc_clock_checker clock_checker;
  minisoc_reset_checker reset_checker;

  function new(string name = "minisoc_env",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    clk_agent = clock_agent::type_id::create("clk_agent", this);
    rst_agent = reset_agent::type_id::create("rst_agent", this);

    clock_checker = minisoc_clock_checker::type_id::create("clock_checker", this);
    reset_checker = minisoc_reset_checker::type_id::create("reset_checker", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    clk_agent.monitor.ap.connect(clock_checker.analysis_export);
    rst_agent.monitor.ap.connect(reset_checker.analysis_export);

    reset_checker.vif = rst_agent.vif;

  endfunction

endclass : minisoc_env