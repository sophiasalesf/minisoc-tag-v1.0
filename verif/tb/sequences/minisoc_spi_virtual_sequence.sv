class minisoc_spi_virtual_sequence
  extends minisoc_virtual_base_sequence;

  `uvm_object_utils(minisoc_spi_virtual_sequence)

  function new(string name = "minisoc_spi_virtual_sequence");
    super.new(name);
  endfunction

  virtual task body();

    clock_sequence    clk_seq;
    reset_sequence    rst_seq;
    spi_sequence      spi_write_seq;
    spi_read_sequence spi_read_seq;

    // Valores usados nos testes dos registradores SPI
    bit [31:0] test_data [0:10] = '{
      32'h12345678, // KEY0 - endereco 0x00
      32'hA1B2C3D4, // KEY1 - endereco 0x01
      32'h0F1E2D3C, // KEY2 - endereco 0x02
      32'h55AA33CC, // KEY3 - endereco 0x03
      32'h10203040, // IV0 - endereco 0x04
      32'h50607080, // IV1 - endereco 0x05
      32'h90ABCDEF, // IV2 - endereco 0x06
      32'hFEDCBA09, // IV3 - endereco 0x07
      32'hCAFEBABE, // COUNTER_HI - endereco 0x08
      32'h0BADF00D, // COUNTER_LO - endereco 0x09
      32'hFFFF0155  // NUM_BLOCKS - endereco 0x0A
      };

    // Enderecos nao implementados selecionados para teste
    bit [5:0] invalid_addrs [0:2] = '{
      6'h10,
      6'h20,
      6'h3E
    };

    // Padroes para testar valores-limite dos registradores
    bit [31:0] boundary_values [0:2] = '{
      32'h00000000, // Todos os bits em zero
      32'hFFFFFFFF, // Todos os bits em um
      32'hAAAA5555  // Padrao alternado de bits
    };

    // Cria as sequences por meio da factory UVM
    clk_seq = clock_sequence::type_id::create("clk_seq");
    rst_seq = reset_sequence::type_id::create("rst_seq");

    spi_write_seq = spi_sequence::type_id::create("spi_write_seq");
    spi_read_seq  = spi_read_sequence::type_id::create("spi_read_seq");

    // Inicia o clock
    clk_seq.start(p_sequencer.clk_seqr);

    // Aplica e libera o reset
    rst_seq.start(p_sequencer.rst_seqr);

    // Percorre KEY0-KEY3, IV0-IV3 e COUNTER_HI/LO
    for (int unsigned addr = 0; addr < 11; addr++) begin

      // Escreve o valor de teste no registrador
      spi_write_seq.write_addr = addr[5:0];
      spi_write_seq.write_data = test_data[addr];
      spi_write_seq.start(p_sequencer.spi_seqr);

      // Solicita a leitura do mesmo registrador
      spi_read_seq.read_addr = addr[5:0];
      spi_read_seq.start(p_sequencer.spi_seqr);

    end

    // AES_CONTROL: configura MODE e DECRYPT sem iniciar o AES
    spi_write_seq.write_addr = 6'h0B;
    spi_write_seq.write_data = 32'hFFFFFFEA;
    spi_write_seq.start(p_sequencer.spi_seqr);


    // Le o AES_CONTROL para verificar os bits armazenados
    spi_read_seq.read_addr = 6'h0B;
    spi_read_seq.start(p_sequencer.spi_seqr);

    // SYSTEM_CONTROL: habilita o PLL com divisor /8
    spi_write_seq.write_addr = 6'h0E;
    spi_write_seq.write_data = 32'h0000000E;
    spi_write_seq.start(p_sequencer.spi_seqr);

    // Le SYSTEM_CONTROL para verificar a configuracao
    spi_read_seq.read_addr = 6'h0E;
    spi_read_seq.start(p_sequencer.spi_seqr);

    // SYSTEM_STATUS: tenta escrever em registrador somente de leitura
    spi_write_seq.write_addr = 6'h0F;
    spi_write_seq.write_data = 32'hDEADBEEF;
    spi_write_seq.start(p_sequencer.spi_seqr);

    // SYSTEM_STATUS: confirma que o PLL permanece LOCKED
    spi_read_seq.read_addr = 6'h0F;
    spi_read_seq.start(p_sequencer.spi_seqr);

    // AES_STATUS: tenta escrever em registrador somente de leitura
    spi_write_seq.write_addr = 6'h0C;
    spi_write_seq.write_data = 32'hDEADBEEF;
    spi_write_seq.start(p_sequencer.spi_seqr);

    // AES_STATUS: confirma que o AES permanece ocioso sem START
    spi_read_seq.read_addr = 6'h0C;
    spi_read_seq.start(p_sequencer.spi_seqr);

    // VERSION: tenta escrever em registrador somente de leitura
    spi_write_seq.write_addr = 6'h0D;
    spi_write_seq.write_data = 32'hDEADBEEF;
    spi_write_seq.start(p_sequencer.spi_seqr);

    // VERSION: confirma que o valor fixo nao foi alterado
    spi_read_seq.read_addr = 6'h0D;
    spi_read_seq.start(p_sequencer.spi_seqr);

    // Testa escrita e leitura de enderecos nao implementados
    foreach (invalid_addrs[i]) begin

      // Escrita deve ser ignorada pelo DUT
      spi_write_seq.write_addr = invalid_addrs[i];
      spi_write_seq.write_data = 32'hDEADBEEF;
      spi_write_seq.start(p_sequencer.spi_seqr);

      // Leitura deve retornar zero
      spi_read_seq.read_addr = invalid_addrs[i];
      spi_read_seq.start(p_sequencer.spi_seqr);

    end

    // Rele todos os registradores validos para verificar
    // se as escritas invalidas alteraram algum valor
    for (int unsigned addr = 0; addr < 16; addr++) begin

      spi_read_seq.read_addr = addr[5:0];
      spi_read_seq.start(p_sequencer.spi_seqr);

    end
    // Testa valores-limite em KEY, IV, COUNTER e NUM_BLOCKS
    foreach (boundary_values[p]) begin

      for (int unsigned addr = 0; addr < 11; addr++) begin

        spi_write_seq.write_addr = addr[5:0];
        spi_write_seq.write_data = boundary_values[p];
        spi_write_seq.start(p_sequencer.spi_seqr);

        spi_read_seq.read_addr = addr[5:0];
        spi_read_seq.start(p_sequencer.spi_seqr);

      end

    end

    // AES_CONTROL: testa mascara de bits sem ativar START
    spi_write_seq.write_addr = 6'h0B;
    spi_write_seq.write_data = 32'hFFFFFFFE;
    spi_write_seq.start(p_sequencer.spi_seqr);

    spi_read_seq.read_addr = 6'h0B;
    spi_read_seq.start(p_sequencer.spi_seqr);

    // AES_CONTROL: testa todos os campos em zero
    spi_write_seq.write_addr = 6'h0B;
    spi_write_seq.write_data = 32'h00000000;
    spi_write_seq.start(p_sequencer.spi_seqr);

    spi_read_seq.read_addr = 6'h0B;
    spi_read_seq.start(p_sequencer.spi_seqr);

    // SYSTEM_CONTROL: testa mascara de bits reservados
    // Mantem PLL habilitado com divisor /8
    spi_write_seq.write_addr = 6'h0E;
    spi_write_seq.write_data = 32'hFFFFFFFE;
    spi_write_seq.start(p_sequencer.spi_seqr);

    spi_read_seq.read_addr = 6'h0E;
    spi_read_seq.start(p_sequencer.spi_seqr);

    // Confirma integridade de todos os registradores validos
    for (int unsigned addr = 0; addr < 16; addr++) begin

      spi_read_seq.read_addr = addr[5:0];
      spi_read_seq.start(p_sequencer.spi_seqr);

    end

  endtask

endclass : minisoc_spi_virtual_sequence
