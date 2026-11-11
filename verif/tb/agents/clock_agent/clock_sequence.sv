class clock_sequence extends uvm_sequence #(clock_item);

  `uvm_object_utils(clock_sequence)

  function new(string name = "clock_sequence");
    super.new(name);
  endfunction

  task body();

    clock_item item;

    item = clock_item::type_id::create("item");

    start_item(item);

    if (!item.randomize() with { period_ps == 500; })
      `uvm_fatal("CLOCK_SEQ", "Falha ao randomizar clock_item")

    finish_item(item);

  endtask

endclass : clock_sequence