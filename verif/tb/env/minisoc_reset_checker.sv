
class minisoc_reset_checker extends uvm_subscriber #(reset_item);

  `uvm_component_utils(minisoc_reset_checker)

  virtual reset_if vif;

  int unsigned sample_count = 0;

  function new(string name = "minisoc_reset_checker",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(reset_item t);

    if (t.assert_reset == 1'b1) begin
      sample_count++;

      if (t.duration == 2ns)
        `uvm_info("RESET_CHECK", "reset observado corretamente", UVM_LOW)
      else
        `uvm_error("RESET_CHECK", "duracao do reset incorreta")
    end

  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    // Verifica se o monitor enviou alguma amostra
    if (sample_count == 0)
      `uvm_error("RESET_CHECK", "nenhuma amostra de reset foi observada")

    // Verifica se a interface foi configurada
    if (vif == null)
      `uvm_fatal("RESET_CHECK", "reset_if nao configurada no checker")

    // Confere se o reset terminou liberado
    else if (vif.rst_n === 1'b1)
      `uvm_info("RESET_CHECK", "reset liberado corretamente", UVM_LOW)
    else
      `uvm_error("RESET_CHECK", "reset nao foi liberado")

  endfunction

endclass : minisoc_reset_checker
