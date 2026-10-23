class reset_item extends uvm_sequence_item;

  `uvm_object_utils(reset_item)

  bit assert_reset;
  realtime duration;

  function new(string name = "reset_item");
    super.new(name);
  endfunction

endclass : reset_item