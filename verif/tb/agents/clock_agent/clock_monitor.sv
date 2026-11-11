class clock_monitor extends uvm_monitor;

  `uvm_component_utils(clock_monitor)

  virtual clock_if vif;

  uvm_analysis_port #(clock_item) ap;

  function new(string name = "clock_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);

    realtime previous_edge;
    realtime current_edge;
    clock_item item;

    @(posedge vif.clk);
    previous_edge = $realtime;

    forever begin
      @(posedge vif.clk);
      current_edge = $realtime;

      item = clock_item::type_id::create("item");
      item.measured_period = current_edge - previous_edge;

      ap.write(item);

      previous_edge = current_edge;
    end

  endtask

endclass : clock_monitor