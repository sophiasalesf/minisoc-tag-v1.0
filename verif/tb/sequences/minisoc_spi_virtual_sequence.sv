
class minisoc_spi_virtual_sequence
  extends minisoc_virtual_base_sequence;

  `uvm_object_utils(minisoc_spi_virtual_sequence)

  function new(string name = "minisoc_spi_virtual_sequence");
    super.new(name);
  endfunction

  virtual task body();

    clock_sequence    clk_seq;
    reset_sequence    rst_seq;
    spi_sequence      spi_write_seq;
    spi_read_sequence spi_read_seq;

    clk_seq = clock_sequence::type_id::create("clk_seq");
    rst_seq = reset_sequence::type_id::create("rst_seq");

    spi_write_seq = spi_sequence::type_id::create("spi_write_seq");
    spi_read_seq  = spi_read_sequence::type_id::create("spi_read_seq");

    // Inicia o clock
    clk_seq.start(p_sequencer.clk_seqr);

    // Aplica e libera o reset
    rst_seq.start(p_sequencer.rst_seqr);

    // Escreve KEY0 pela interface SPI
    spi_write_seq.start(p_sequencer.spi_seqr);

    // Lê KEY0 e permite sua verificação pelo checker
    spi_read_seq.start(p_sequencer.spi_seqr);

  endtask

endclass : minisoc_spi_virtual_sequence
