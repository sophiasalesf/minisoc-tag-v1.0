`uvm_analysis_imp_decl(_reset)

class minisoc_spi_checker extends uvm_subscriber #(spi_item);

  `uvm_component_utils(minisoc_spi_checker)

  // Entrada para receber eventos do monitor de RESET
  uvm_analysis_imp_reset #(reset_item, minisoc_spi_checker) reset_export;

  // Valores esperados para KEY0-KEY3, IV0-IV3 e COUNTER_HI/LO
  bit [31:0] expected_data [0:14];
  bit reg_written [0:14];

  // Controle da leitura SPI em dois frames
  bit read_pending = 1'b0;
  bit [5:0] pending_addr;

  int unsigned write_count = 0;
  int unsigned read_count = 0;
  int unsigned frame_count = 0;

  function new(string name = "minisoc_spi_checker", uvm_component parent = null);
    super.new(name, parent);
    reset_export = new("reset_export", this);
  endfunction

  // Atualiza o modelo esperado quando um reset e observado
  function void write_reset(reset_item t);

    if (t.assert_reset == 1'b1) begin

      // Inicializa os valores e marcadores de escrita
      for (int i = 0; i < 15; i++) begin
        expected_data[i] = 32'b0;
        reg_written[i] = 1'b0;
      end

      // Registradores de configuracao possuem valores
      // definidos mesmo antes da primeira escrita SPI
      for (int i = 0; i <= 11; i++)
        reg_written[i] = 1'b1;

      // Valores de reset definidos pelo RTL
      expected_data[10] = 32'h00000001; // NUM_BLOCKS
      expected_data[14] = 32'h0000000C; // SYSTEM_CONTROL
      reg_written[14] = 1'b1;

      // Descarta qualquer leitura pendente do estado anterior
      read_pending = 1'b0;
      pending_addr = 6'b0;

      `uvm_info("SPI_CHECK",
                "Modelo dos registradores reiniciado apos reset",
                UVM_LOW)

    end

  endfunction

  function void write(spi_item t);

    bit [31:0] expected_read;

    // Um frame incompleto nao representa comando valido
    if (t.nbits != 40) begin

      `uvm_info("SPI_CHECK",
                $sformatf("Frame incompleto ignorado: %0d bits", t.nbits),
                UVM_LOW)

      return;

    end

    frame_count++;

    // Verifica a resposta solicitada no frame anterior
    if (read_pending) begin

      read_pending = 1'b0;
      read_count++;

      // VERSION: valor fixo
      if (pending_addr == 6'h0D)
        expected_read = 32'h0001_0100;

      // AES_STATUS: estado ocioso, sem comando START
      else if (pending_addr == 6'h0C)
        expected_read = 32'h00000000;

      // SYSTEM_STATUS: bit 0 indica PLL_LOCKED
      else if (pending_addr == 6'h0F) begin
        if (reg_written[14])
          expected_read = {31'b0, expected_data[14][1]};
        else
          expected_read = 32'b0;
      end

      // Enderecos nao implementados retornam zero
      else if (pending_addr >= 6'h10 && pending_addr <= 6'h3E)
        expected_read = 32'h00000000;

      else
        expected_read = expected_data[pending_addr];

      if (t.read_data === expected_read)
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
                     expected_read,
                     t.read_data))

    end

    // Registradores de configuracao SPI
    if (t.addr <= 6'h0B || t.addr == 6'h0E) begin

      if (t.rwb == 1'b0) begin

        // NUM_BLOCKS armazena somente os 9 bits inferiores
        if (t.addr == 6'h0A)
          expected_data[t.addr] = {23'b0, t.data[8:0]};

        // AES_CONTROL retorna apenas MODE e DECRYPT
        else if (t.addr == 6'h0B)
          expected_data[t.addr] = t.data & 32'h0000001E;

        // SYSTEM_CONTROL armazena apenas os bits [3:0]
        else if (t.addr == 6'h0E)
          expected_data[t.addr] = t.data & 32'h0000000F;

        else
          expected_data[t.addr] = t.data;

        reg_written[t.addr] = 1'b1;
        write_count++;

        `uvm_info("SPI_CHECK", $sformatf("Escrita observada no endereco 0x%02h: 0x%08h", t.addr, t.data), UVM_LOW)

      end
      else begin

        if (!reg_written[t.addr])
          `uvm_error("SPI_CHECK", $sformatf("Leitura do endereco 0x%02h sem escrita anterior", t.addr))
        else begin
          pending_addr = t.addr;
          read_pending = 1'b1;
        end

      end

    end

    // AES_STATUS, VERSION e SYSTEM_STATUS: somente leitura
    else if (t.rwb == 1'b1 &&
             (t.addr == 6'h0C ||
              t.addr == 6'h0D ||
              t.addr == 6'h0F)) begin

      pending_addr = t.addr;
      read_pending = 1'b1;

    end

    // Leituras de enderecos nao implementados
    else if (t.rwb == 1'b1 &&
             t.addr >= 6'h10 && t.addr <= 6'h3E) begin

      pending_addr = t.addr;
      read_pending = 1'b1;

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
