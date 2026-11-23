
class minisoc_virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);

  `uvm_component_utils(minisoc_virtual_sequencer)

  // Handles dos sequencers dos agentes
  clock_sequencer clk_seqr;
  reset_sequencer rst_seqr;
  spi_sequencer   spi_seqr;

  function new(string name = "minisoc_virtual_sequencer",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass : minisoc_virtual_sequencer
