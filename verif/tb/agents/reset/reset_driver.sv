class reset_driver extends uvm_driver #(reset_item);

  `uvm_component_utils(reset_driver)

  virtual reset_if vif;

  function new(string name = "reset_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    reset_item item;

    vif.rst_n = 1'b0;

    forever begin
      seq_item_port.get_next_item(item);

      if (item.assert_reset)
        vif.rst_n = 1'b0;
      else
        vif.rst_n = 1'b1;

      #(item.duration);

      seq_item_port.item_done();
    end

  endtask

endclass : reset_driver