class memory_data_driver extends uvm_driver #(memory_data_item);

  `uvm_component_utils(memory_data_driver)

  virtual memory_data_if vif;

  function new(string name = "memory_data_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    memory_data_item item;

    // Estado inicial da interface
    vif.clk    = 1'b0;
    vif.i_data = 32'b0;
    vif.wr_en  = 1'b0;
    vif.addr   = 10'b0;

    forever begin

      seq_item_port.get_next_item(item);

      // Prepara os sinais antes da borda de subida
      vif.addr   = item.addr;
      vif.i_data = item.data;
      vif.wr_en  = item.wr_en;

      #5ns;

      // A memoria realiza o acesso nesta borda
      vif.clk = 1'b1;

      // Aguarda a atualizacao da saida sincronizada
      #1ns;

      if (item.wr_en == 1'b0)
        item.read_data = vif.o_data;

      #4ns;

      vif.clk = 1'b0;

      seq_item_port.item_done();

    end

  endtask

endclass : memory_data_driver