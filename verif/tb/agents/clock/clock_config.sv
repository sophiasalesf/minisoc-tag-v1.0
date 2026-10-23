class clock_config extends uvm_object;

  `uvm_object_utils(clock_config)

  realtime period = 500ps;
  bit enabled = 1'b1;

  function new(string name = "clock_config");
    super.new(name);
  endfunction

endclass : clock_config