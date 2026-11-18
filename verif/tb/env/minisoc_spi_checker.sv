
class minisoc_spi_checker extends uvm_subscriber #(spi_item);

  `uvm_component_utils(minisoc_spi_checker)

  bit [31:0] expected_key0;
  bit key0_written = 1'b0;
  bit read_pending = 1'b0;

  int unsigned write_count = 0;
  int unsigned read_count = 0;
  int unsigned frame_count = 0;

  function new(string name = "minisoc_spi_checker",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(spi_item t);

    frame_count++;

    // Resposta ao pedido de leitura anterior
    if (read_pending) begin

      read_pending = 1'b0;
      read_count++;

      if (t.read_data === expected_key0)
        `uvm_info("SPI_CHECK",
                  "Leitura de KEY0 corresponde ao valor escrito",
                  UVM_LOW)
      else
        `uvm_error("SPI_CHECK",
                   $sformatf(
                     "KEY0 incorreto: esperado=0x%08h, recebido=0x%08h",
                     expected_key0, t.read_data))

    end

    // Escrita no registrador KEY0
    if (t.rwb == 1'b0 && t.addr == 6'h00) begin

      expected_key0 = t.data;
      key0_written = 1'b1;
      write_count++;

      `uvm_info("SPI_CHECK",
                "Escrita SPI em KEY0 observada",
                UVM_LOW)

    end

    // Pedido de leitura do registrador KEY0
    if (t.rwb == 1'b1 && t.addr == 6'h00) begin

      if (!key0_written)
        `uvm_error("SPI_CHECK",
                   "Leitura de KEY0 sem escrita anterior")
      else
        read_pending = 1'b1;

    end

  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    // O smoke de CLOCK/RESET nao executa transacoes SPI
    if (frame_count == 0)
      return;

    // Quando ha atividade SPI, verifica o cenario KEY0
    if (write_count == 0)
      `uvm_error("SPI_CHECK",
                "Nenhuma escrita em KEY0 foi observada")

    if (read_count == 0)
      `uvm_error("SPI_CHECK",
                "Nenhuma resposta de leitura foi observada")

    if (read_pending)
      `uvm_error("SPI_CHECK",
                "Leitura SPI pendente sem resposta")

  endfunction


endclass : minisoc_spi_checker
