
class minisoc_smoke_test extends uvm_test;

  `uvm_component_utils(minisoc_smoke_test)

  minisoc_env env;

  function new(string name = "minisoc_smoke_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = minisoc_env::type_id::create("env", this);
  endfunction


  task run_phase(uvm_phase phase);

    clock_sequence clk_seq;
    reset_sequence rst_seq;

    phase.raise_objection(this);

    // Inicia o clock de referencia de 2 GHz
    clk_seq = clock_sequence::type_id::create("clk_seq");
    clk_seq.start(env.clk_agent.sequencer);

    // Executa o cenario de reset
    rst_seq = reset_sequence::type_id::create("rst_seq");
    rst_seq.start(env.rst_agent.sequencer);

    phase.drop_objection(this);

  endtask


endclass : minisoc_smoke_test
