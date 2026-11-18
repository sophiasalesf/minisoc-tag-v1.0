
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

    clock_sequence    clk_seq;
    reset_sequence    rst_seq;
    spi_sequence      spi_seq;
    spi_read_sequence spi_read_seq;

    phase.raise_objection(this);

    // Inicia o clock de referencia de 2 GHz
    clk_seq = clock_sequence::type_id::create("clk_seq");
    clk_seq.start(env.clk_agent.sequencer);

    // Aplica e libera o reset
    rst_seq = reset_sequence::type_id::create("rst_seq");
    rst_seq.start(env.rst_agent.sequencer);

    // Escreve 0x12345678 no registrador KEY0
    spi_seq = spi_sequence::type_id::create("spi_seq");
    spi_seq.start(env.spi_agt.sequencer);

    `uvm_info("SPI_TEST", "Escrita SPI concluida", UVM_LOW)

    // Solicita a leitura e recebe a resposta SPI
    spi_read_seq = spi_read_sequence::type_id::create("spi_read_seq");
    spi_read_seq.start(env.spi_agt.sequencer);

    phase.drop_objection(this);

  endtask


endclass : minisoc_spi_test
