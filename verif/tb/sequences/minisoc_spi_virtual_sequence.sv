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

    // VERSION: leitura de registrador somente de leitura
    spi_read_seq.read_addr = 6'h0D;
    spi_read_seq.start(p_sequencer.spi_seqr);

  endtask

endclass : minisoc_spi_virtual_sequence
