class minisoc_memory_sequence
  extends uvm_sequence #(memory_data_item);

  `uvm_object_utils(minisoc_memory_sequence)

  function new(string name = "minisoc_memory_sequence");
    super.new(name);
  endfunction

  // Envia uma operacao de escrita ou leitura
  task send_access(
    bit wr,
    bit [9:0] address,
    bit [31:0] value
  );

    memory_data_item item;

    item = memory_data_item::type_id::create("item");

    start_item(item);

    item.wr_en = wr;
    item.addr  = address;
    item.data  = value;

    finish_item(item);

  endtask

  task body();

    // Escreve valores conhecidos em diferentes enderecos
    send_access(1'b1, 10'd0,    32'h12345678);
    send_access(1'b1, 10'd1,    32'hFFFFFFFF);
    send_access(1'b1, 10'd511,  32'hA5A55A5A);
    send_access(1'b1, 10'd1023, 32'hCAFEBABE);

    // Le os mesmos enderecos
    send_access(1'b0, 10'd0,    32'h0);
    send_access(1'b0, 10'd1,    32'h0);
    send_access(1'b0, 10'd511,  32'h0);
    send_access(1'b0, 10'd1023, 32'h0);

    // Sobrescreve e verifica novamente um endereco
    send_access(1'b1, 10'd1, 32'hDEADBEEF);
    send_access(1'b0, 10'd1, 32'h0);

  endtask

endclass : minisoc_memory_sequence