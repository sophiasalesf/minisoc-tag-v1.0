class reset_sequence extends uvm_sequence #(reset_item);

  `uvm_object_utils(reset_sequence)

  function new(string name = "reset_sequence");
    super.new(name);
  endfunction

  task body();

    reset_item item;

    item = reset_item::type_id::create("item");

    start_item(item);
    item.assert_reset = 1'b1;
    item.duration = 2ns;
    finish_item(item);

    start_item(item);
    item.assert_reset = 1'b0;
    item.duration = 1ns;
    finish_item(item);

  endtask

endclass : reset_sequence