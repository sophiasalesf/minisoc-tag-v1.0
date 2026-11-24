class memory_data_monitor extends uvm_monitor;

  `uvm_component_utils(memory_data_monitor)

  virtual memory_data_if vif;

  uvm_analysis_port #(memory_data_item) ap;

  function new(string name = "memory_data_monitor",
               uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);

    memory_data_item item;

    forever begin

      // Uma borda de subida representa um acesso
      @(posedge vif.clk);

      item = memory_data_item::type_id::create("item");

      // Captura os sinais presentes na borda
      item.wr_en = vif.wr_en;
      item.addr  = vif.addr;
      item.data  = vif.i_data;

      // Aguarda a atualizacao da saida da memoria
      #1ns;

      if (item.wr_en == 1'b0) begin

        item.read_data = vif.o_data;

        `uvm_info("MEM_MON",
          $sformatf("READ addr=0x%03h data=0x%08h",
                    item.addr, item.read_data),
          UVM_LOW)

      end
      else begin

        `uvm_info("MEM_MON",
          $sformatf("WRITE addr=0x%03h data=0x%08h",
                    item.addr, item.data),
          UVM_LOW)

      end

      // Disponibiliza a transacao observada
      ap.write(item);

    end

  endtask

endclass : memory_data_monitor