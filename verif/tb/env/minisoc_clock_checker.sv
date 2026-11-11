
class minisoc_clock_checker extends uvm_subscriber #(clock_item);

  `uvm_component_utils(minisoc_clock_checker)

  int unsigned sample_count = 0;

  function new(string name = "minisoc_clock_checker",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(clock_item t);

    sample_count++;

    if (t.measured_period == 500ps)
      `uvm_info("CLOCK_CHECK", "clock de 2 GHz correto", UVM_LOW)
    else
      `uvm_error("CLOCK_CHECK", "periodo do clock incorreto")

  endfunction

endclass : minisoc_clock_checker
