class clock_generator extends uvm_component;

  `uvm_component_utils(clock_generator)

  virtual clock_if vif;
  clock_config cfg;

  function new(string name = "clock_generator", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    vif.clk = 1'b0;

    forever begin
      if (cfg.enabled) begin
        #(cfg.period / 2);
        vif.clk = ~vif.clk;
      end
      else begin
        vif.clk = 1'b0;
        #(cfg.period / 2);
      end
    end

  endtask

endclass : clock_generator