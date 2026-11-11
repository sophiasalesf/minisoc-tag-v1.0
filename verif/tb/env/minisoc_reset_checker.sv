
class minisoc_reset_checker extends uvm_subscriber #(reset_item);

  `uvm_component_utils(minisoc_reset_checker)

  int unsigned sample_count = 0;

  function new(string name = "minisoc_reset_checker",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(reset_item t);

    if (t.assert_reset == 1'b1) begin
      sample_count++;

      if (t.duration == 2ns)
        `uvm_info("RESET_CHECK", "reset observado corretamente", UVM_LOW)
      else
        `uvm_error("RESET_CHECK", "duracao do reset incorreta")
    end

  endfunction

endclass : minisoc_reset_checker
