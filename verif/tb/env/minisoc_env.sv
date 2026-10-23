class minisoc_env extends uvm_env;

  `uvm_component_utils(minisoc_env)

  clock_agent clk_agent;
  reset_agent rst_agent;

  function new(string name = "minisoc_env",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    clk_agent = clock_agent::type_id::create("clk_agent", this);
    rst_agent = reset_agent::type_id::create("rst_agent", this);
  endfunction

endclass : minisoc_env