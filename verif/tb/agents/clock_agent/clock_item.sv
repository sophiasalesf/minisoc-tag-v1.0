class clock_item extends uvm_sequence_item;

  `uvm_object_utils(clock_item)

  // Periodo solicitado para gerar o clock, em ps
  rand int unsigned period_ps = 500;

  // Periodo observado pelo monitor
  realtime measured_period;

  // O periodo deve ser positivo e par
  constraint c_period_ps {
    period_ps > 0;
    period_ps % 2 == 0;
  }

  function new(string name = "clock_item");
    super.new(name);
  endfunction

endclass : clock_item