class minisoc_clock_checker extends uvm_subscriber #(clock_item);

  `uvm_component_utils(minisoc_clock_checker)

  int unsigned sample_count = 0;

  function new(string name = "minisoc_clock_checker",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(clock_item t);

    sample_count++;

    if (t.measured_period == 500ps)
      `uvm_info("CLOCK_CHECK", "clock de 2 GHz correto", UVM_LOW)
    else
      `uvm_error("CLOCK_CHECK", "periodo do clock incorreto")

  endfunction

endclass : minisoc_clock_checker

class minisoc_reset_checker extends uvm_subscriber #(reset_item);

  `uvm_component_utils(minisoc_reset_checker)
  
  int unsigned sample_count = 0;

  function new(string name = "minisoc_reset_checker",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(reset_item t);

    if (t.assert_reset == 1'b1) begin
      sample_count++;

      if (t.duration == 2ns)
        `uvm_info("RESET_CHECK", "reset observado corretamente", UVM_LOW)
      else 
        `uvm_error("RESET_CHECK", "duracao do reset incorreta")

    end

  endfunction

endclass : minisoc_reset_checker

class minisoc_smoke_test extends uvm_test;

  `uvm_component_utils(minisoc_smoke_test)

  minisoc_env env;

  minisoc_clock_checker clock_checker;

  minisoc_reset_checker reset_checker;

  function new(string name = "minisoc_smoke_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = minisoc_env::type_id::create("env", this);

    clock_checker = minisoc_clock_checker::type_id::create("clock_checker", this);

    reset_checker = minisoc_reset_checker::type_id::create("reset_checker", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    env.clk_agent.monitor.ap.connect(clock_checker.analysis_export);

    env.rst_agent.monitor.ap.connect(reset_checker.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);

    reset_sequence rst_seq;

    phase.raise_objection(this);

    rst_seq = reset_sequence::type_id::create("rst_seq");
    rst_seq.start(env.rst_agent.sequencer);

    if (env.rst_agent.vif.rst_n == 1'b1)
      `uvm_info("RESET_CHECK", "reset liberado corretamente", UVM_LOW)
    else
      `uvm_error("RESET_CHECK", "reset nao foi liberado")

    if (clock_checker.sample_count == 0)
      `uvm_error("CLOCK_CHECK", "nenhuma amostra de clock foi observada")

    if (reset_checker.sample_count == 0)
      `uvm_error("RESET_CHECK", "nenhuma amostra de reset foi observada")

    phase.drop_objection(this);

  endtask

endclass : minisoc_smoke_test