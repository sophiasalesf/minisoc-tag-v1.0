class reset_monitor extends uvm_monitor;

  `uvm_component_utils(reset_monitor)

  virtual reset_if vif;

  uvm_analysis_port #(reset_item) ap;

  function new(string name = "reset_monitor",
               uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);

    realtime start_time;
    realtime end_time;
    bit current_asserted;
    reset_item item;

    wait (vif.rst_n === 1'b0 || vif.rst_n === 1'b1);

    current_asserted = (vif.rst_n == 1'b0);
    start_time = $realtime;

    forever begin
      @(vif.rst_n);

      end_time = $realtime;

      item = reset_item::type_id::create("item");
      item.assert_reset = current_asserted;
      item.duration = end_time - start_time;

      ap.write(item);

      current_asserted = (vif.rst_n == 1'b0);
      start_time = end_time;
    end

  endtask

endclass : reset_monitor