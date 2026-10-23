class clock_item extends uvm_sequence_item;

  `uvm_object_utils(clock_item)

  realtime measured_period;

  function new(string name = "clock_item");
    super.new(name);
  endfunction

endclass : clock_item