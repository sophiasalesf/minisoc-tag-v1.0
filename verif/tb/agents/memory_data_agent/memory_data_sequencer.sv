class memory_data_sequencer
  extends uvm_sequencer #(memory_data_item);

  `uvm_component_utils(memory_data_sequencer)

  function new(string name = "memory_data_sequencer",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass : memory_data_sequencer