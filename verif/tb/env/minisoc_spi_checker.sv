
class minisoc_spi_checker extends uvm_subscriber #(spi_item);

  `uvm_component_utils(minisoc_spi_checker)

  // Valores esperados para KEY0-KEY3, IV0-IV3 e COUNTER_HI/LO
  bit [31:0] expected_data [0:10];
  bit reg_written [0:10];

  // Controle da leitura SPI em dois frames
  bit read_pending = 1'b0;
  bit [5:0] pending_addr;

  int unsigned write_count = 0;
  int unsigned read_count = 0;
  int unsigned frame_count = 0;

  function new(string name = "minisoc_spi_checker", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(spi_item t);

    frame_count++;

    // Verifica a resposta solicitada no frame anterior
    if (read_pending) begin

      read_pending = 1'b0;
      read_count++;

      if (t.read_data === expected_data[pending_addr])
        `uvm_info("SPI_CHECK",
                  $sformatf(
                    "Leitura do endereco 0x%02h correta: 0x%08h",
                    pending_addr, t.read_data),
                  UVM_LOW)
      else
        `uvm_error("SPI_CHECK",
                   $sformatf(
                     "Endereco 0x%02h incorreto: esperado=0x%08h, recebido=0x%08h",
                     pending_addr,
                     expected_data[pending_addr],
                     t.read_data))

    end

    // Registradores KEY0-KEY3, IV0-IV3 e COUNTER_HI/LO
    if (t.addr <= 6'h0A) begin

      // Escrita SPI
      if (t.rwb == 1'b0) begin

        // NUM_BLOCKS armazena somente os 9 bits inferiores
        if (t.addr == 6'h0A)
          expected_data[t.addr] = {23'b0, t.data[8:0]};
        else
          expected_data[t.addr] = t.data;

        reg_written[t.addr] = 1'b1;
        write_count++;

        `uvm_info("SPI_CHECK", $sformatf("Escrita observada no endereco 0x%02h: 0x%08h", t.addr, t.data), UVM_LOW)

      end

      // Pedido de leitura SPI
      else begin

        if (!reg_written[t.addr])
          `uvm_error("SPI_CHECK", $sformatf("Leitura do endereco 0x%02h sem escrita anterior", t.addr))
        else begin
          pending_addr = t.addr;
          read_pending = 1'b1;
        end

      end

    end

  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    // Smoke de CLOCK/RESET nao executa transacoes SPI
    if (frame_count == 0)
      return;

    if (write_count == 0)
      `uvm_error("SPI_CHECK", "Nenhuma escrita SPI foi observada")

    if (read_count == 0)
      `uvm_error("SPI_CHECK", "Nenhuma resposta de leitura SPI foi observada")

    if (read_pending)
      `uvm_error("SPI_CHECK", "Leitura SPI pendente sem resposta")

  endfunction

endclass : minisoc_spi_checker
