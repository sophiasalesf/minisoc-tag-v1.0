class minisoc_env extends uvm_env;

  `uvm_component_utils(minisoc_env)

  clock_agent clk_agent;
  reset_agent rst_agent;
  spi_agent spi_agt;
  memory_data_agent mem_agt;
  minisoc_virtual_sequencer virtual_sequencer;

  minisoc_clock_checker clock_checker;
  minisoc_reset_checker reset_checker;
  minisoc_spi_checker spi_checker;
  minisoc_memory_checker memory_checker;

  function new(string name = "minisoc_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    clk_agent = clock_agent::type_id::create("clk_agent", this);
    rst_agent = reset_agent::type_id::create("rst_agent", this);
    spi_agt = spi_agent::type_id::create("spi_agt", this);
    mem_agt = memory_data_agent::type_id::create("mem_agt", this);
    virtual_sequencer = minisoc_virtual_sequencer::type_id::create("virtual_sequencer", this);

    clock_checker = minisoc_clock_checker::type_id::create("clock_checker", this);

    reset_checker = minisoc_reset_checker::type_id::create("reset_checker", this);

    spi_checker = minisoc_spi_checker::type_id::create("spi_checker", this);

    memory_checker = minisoc_memory_checker::type_id::create("memory_checker", this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    clk_agent.monitor.ap.connect(clock_checker.analysis_export);
    rst_agent.monitor.ap.connect(reset_checker.analysis_export);
    spi_agt.monitor.ap.connect(spi_checker.analysis_export);
    mem_agt.monitor.ap.connect(memory_checker.analysis_export);

    // Envia eventos de reset tambem para o checker SPI
    rst_agent.monitor.ap.connect(spi_checker.reset_export);

    reset_checker.vif = rst_agent.vif;

    virtual_sequencer.clk_seqr = clk_agent.sequencer;
    virtual_sequencer.rst_seqr = rst_agent.sequencer;
    virtual_sequencer.spi_seqr = spi_agt.sequencer;
    virtual_sequencer.mem_seqr = mem_agt.sequencer;
  endfunction

endclass : minisoc_env
