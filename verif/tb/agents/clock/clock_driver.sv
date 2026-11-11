class clock_driver extends uvm_driver #(clock_item);

  `uvm_component_utils(clock_driver)

  virtual clock_if vif;

  function new(string name = "clock_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    clock_item item;
    int unsigned period_ps;

    vif.clk = 1'b0;

    // Recebe a configuracao enviada pela sequence
    seq_item_port.get_next_item(item);

    period_ps = item.period_ps;

    seq_item_port.item_done();

    // Gera o clock continuamente
    forever begin
      #((period_ps / 2) * 1ps);
      vif.clk = ~vif.clk;
    end

  endtask

endclass : clock_driver