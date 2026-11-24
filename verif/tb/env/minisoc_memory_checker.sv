class minisoc_memory_checker
  extends uvm_subscriber #(memory_data_item);

  `uvm_component_utils(minisoc_memory_checker)

  bit [31:0] expected_data [0:1023];
  bit initialized [0:1023];

  int unsigned write_count;
  int unsigned read_count;
  int unsigned checked_reads;

  function new(
    string name = "minisoc_memory_checker",
    uvm_component parent = null
  );
    super.new(name, parent);

    foreach (initialized[i])
      initialized[i] = 1'b0;
  endfunction

  function void write(memory_data_item t);

    if (t.wr_en) begin

      // Registra o valor esperado apos uma escrita
      expected_data[t.addr] = t.data;
      initialized[t.addr] = 1'b1;
      write_count++;

    end
    else begin

      read_count++;

      // A memoria nao possui reset:
      // so podemos comparar enderecos ja escritos
      if (!initialized[t.addr]) begin

        `uvm_error("MEM_CHECK",
          $sformatf(
            "Leitura de endereco nao inicializado: 0x%03h",
            t.addr
          ))

      end
      else if (t.read_data !== expected_data[t.addr]) begin

        `uvm_error("MEM_CHECK",
          $sformatf(
            "Mismatch addr=0x%03h esperado=0x%08h recebido=0x%08h",
            t.addr, expected_data[t.addr], t.read_data
          ))

      end
      else begin

        checked_reads++;

        `uvm_info("MEM_CHECK",
          $sformatf(
            "READ OK addr=0x%03h data=0x%08h",
            t.addr, t.read_data
          ),
          UVM_LOW)

      end

    end

  endfunction

endclass : minisoc_memory_checker