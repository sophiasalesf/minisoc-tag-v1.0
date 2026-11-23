
class minisoc_virtual_base_sequence extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(minisoc_virtual_base_sequence)

  `uvm_declare_p_sequencer(minisoc_virtual_sequencer)

  function new(string name = "minisoc_virtual_base_sequence");
    super.new(name);
  endfunction

endclass : minisoc_virtual_base_sequence
