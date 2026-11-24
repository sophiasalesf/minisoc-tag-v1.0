class memory_data_item extends uvm_sequence_item;

  `uvm_object_utils(memory_data_item)

  // Campos da transacao MEMORY DATA
  rand bit        wr_en;
  rand bit [9:0]  addr;
  rand bit [31:0] data;

  // Dado observado durante uma leitura
  logic [31:0] read_data;

  function new(string name = "memory_data_item");
    super.new(name);
  endfunction

endclass : memory_data_item