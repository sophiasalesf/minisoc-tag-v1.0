
class minisoc_spi_test extends uvm_test;

  `uvm_component_utils(minisoc_spi_test)

  minisoc_env env;

  function new(string name = "minisoc_spi_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = minisoc_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);

    minisoc_spi_virtual_sequence virtual_seq;

    phase.raise_objection(this);

    // Cria a virtual sequence que coordena CLOCK, RESET e SPI
    virtual_seq = minisoc_spi_virtual_sequence::type_id::create(
      "virtual_seq"
    );

    // Executa o cenario no virtual sequencer do ambiente
    virtual_seq.start(env.virtual_sequencer);

    `uvm_info("SPI_TEST",
              "Cenario SPI executado pela virtual sequence",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : minisoc_spi_test
