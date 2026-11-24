class minisoc_memory_test extends uvm_test;

  `uvm_component_utils(minisoc_memory_test)

  minisoc_env env;

  function new(
    string name = "minisoc_memory_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = minisoc_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);

    clock_sequence clk_seq;
    reset_sequence rst_seq;
    minisoc_memory_sequence mem_seq;

    phase.raise_objection(this);

    // Inicializa o sistema
    clk_seq = clock_sequence::type_id::create("clk_seq");
    clk_seq.start(env.clk_agent.sequencer);

    rst_seq = reset_sequence::type_id::create("rst_seq");
    rst_seq.start(env.rst_agent.sequencer);

    // Apos reset, MEM_SEL_AES = 0:
    // a interface externa controla a memoria
    mem_seq = minisoc_memory_sequence::type_id::create(
      "mem_seq"
    );

    mem_seq.start(env.mem_agt.sequencer);

    phase.drop_objection(this);

  endtask

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    if (env.memory_checker.write_count != 5 ||
        env.memory_checker.read_count != 5 ||
        env.memory_checker.checked_reads != 5) begin

      `uvm_error("MEM_TEST",
        $sformatf(
          "Transacoes incompletas: writes=%0d reads=%0d reads_ok=%0d",
          env.memory_checker.write_count,
          env.memory_checker.read_count,
          env.memory_checker.checked_reads
        ))

    end

  endfunction

endclass : minisoc_memory_test