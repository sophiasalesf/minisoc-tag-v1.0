
class reset_sequence extends uvm_sequence #(reset_item);

  `uvm_object_utils(reset_sequence)

  function new(string name = "reset_sequence");
    super.new(name);
  endfunction

  task body();

    reset_item assert_item;
    reset_item release_item;

    // Primeira transacao: aplica reset por 2 ns
    assert_item = reset_item::type_id::create("assert_item");

    start_item(assert_item);
    assert_item.assert_reset = 1'b1;
    assert_item.duration = 2ns;
    finish_item(assert_item);

    // Segunda transacao: libera reset por 1 ns
    release_item = reset_item::type_id::create("release_item");

    start_item(release_item);
    release_item.assert_reset = 1'b0;
    release_item.duration = 1ns;
    finish_item(release_item);

  endtask

endclass : reset_sequence