`timescale 1ns/1ps

module tb_cache_top();

    logic clk;
    logic reset;
    logic cpu_read;
    logic cpu_write;
    logic [7:0]  cpu_addr;  // A memória possui 256 posições de endereçamento
    logic [31:0] cpu_wdata; // A arquitetura trabalha com palavras de 32 bits para gravação
    logic [31:0] cpu_rdata; // A arquitetura trabalha com palavras de 32 bits para leitura
    logic cpu_ready;
    logic cache_hit;

    // Contadores de log
    int tests_passed = 0;
    int tests_failed = 0;
    int total_tests  = 0;

    // Instancia a Cache principal
    cache_top #(
        .MEM_LATENCY(5)
    ) dut (
        .clk       (clk),
        .reset     (reset),
        .cpu_read  (cpu_read),
        .cpu_write (cpu_write),
        .cpu_addr  (cpu_addr),
        .cpu_wdata (cpu_wdata),
        .cpu_rdata (cpu_rdata),
        .cpu_ready (cpu_ready),
        .cache_hit (cache_hit)
    );

    // Gera o clock (alterna a cada 5ns)
    always #5 clk = ~clk;



    // Exibe [PASS] ou [FAIL] e conta os testes
    task check_assert(input string test_name, input logic condition);
        total_tests++;
        if (condition) begin
            $display("[PASS] %s", test_name);
            tests_passed++;
        end else begin
            $display("[FAIL] %s", test_name);
            tests_failed++;
        end
    endtask

    // Simula uma escrita da CPU aguardando a cache responder
    task write_cache(input [7:0] w_addr, input [31:0] data, output logic hit_out);
        @(posedge clk);
        cpu_addr  = w_addr;
        cpu_wdata = data;
        cpu_write = 1'b1;
        cpu_read  = 1'b0;
        
        wait(cpu_ready == 1'b1);
        @(posedge clk);
        
        hit_out   = cache_hit;
        cpu_write = 1'b0;
    endtask

    // Simula uma leitura da CPU aguardando a cache responder
    task read_cache(input [7:0] r_addr, output [31:0] data_out, output logic hit_out);
        @(posedge clk);
        cpu_addr  = r_addr;
        cpu_read  = 1'b1;
        cpu_write = 1'b0;
        
        wait(cpu_ready == 1'b1);
        @(posedge clk);
        
        data_out = cpu_rdata;
        hit_out  = cache_hit;
        cpu_read = 1'b0;
    endtask


    // Casos de teste: 
    task test_edge_cases();
        logic [31:0] read_val;
        logic hit_status;
        $display("\n--- 7.5: CASOS LIMITE ---");
        
        reset = 1; #20; reset = 0; #10;
        
        // Lê os extremos da memória em cache vazia (espera MISS)
        read_cache(8'h00, read_val, hit_status);
        check_assert("Acesso 0x00 da MISS", hit_status == 0);

        read_cache(8'hFF, read_val, hit_status);
        check_assert("Acesso 0xFF da MISS", hit_status == 0);
        
        // Primeira gravação logo após ligar a cache
        write_cache(8'h04, 32'hBEEFCAFE, hit_status); 
        read_cache(8'h04, read_val, hit_status);
        check_assert("Leitura pos escrita funciona", (read_val == 32'hBEEFCAFE) && (hit_status == 1));
    endtask

    task test_consistency();
        logic [31:0] read_val;
        logic hit_status;
        $display("\n--- 7.4: CONSISTENCIA ---");

        // Traz da memória, modifica e lê para confirmar (Read -> Write -> Read)
        read_cache(8'hA0, read_val, hit_status); 
        write_cache(8'hA0, 32'hCAFEF00D, hit_status);
        read_cache(8'hA0, read_val, hit_status);      
        check_assert("Dado alterado gravou certo (HIT)", (read_val == 32'hCAFEF00D) && (hit_status == 1));

        // Lê repetidas vezes para garantir que o dado não some
        read_cache(8'hA0, read_val, hit_status);
        check_assert("Leitura repetida da HIT", hit_status == 1);

        // Força conflito lendo 3 endereços que vão para o mesmo Índice
        read_cache(8'hB0, read_val, hit_status); 
        read_cache(8'hC0, read_val, hit_status); // Vai expulsar alguém!
        check_assert("Terceira leitura forcou conflito (MISS)", hit_status == 0);
        
        // Verifica se o último que entrou continuou lá
        read_cache(8'hC0, read_val, hit_status);
        check_assert("Dado novo esta integro pos conflito", hit_status == 1);
    endtask

    task test_replacement();
        logic [31:0] read_val;
        logic hit_status;
        $display("\n--- 7.3: SUBSTITUICAO E WRITE-BACK ---");

        reset = 1; #20; reset = 0; #10;

        // Lota as duas vias (espaços) do Índice 0
        read_cache(8'h00, read_val, hit_status); 
        read_cache(8'h10, read_val, hit_status); 

        // Escreve na Via 0 para deixá-la "suja" (dirty)
        write_cache(8'h00, 32'h99999999, hit_status);
        
        // Lê a Via 1 para que a Via 0 vire a candidata a ser expulsa (LRU)
        read_cache(8'h10, read_val, hit_status); 

        // Lê um terceiro endereço forçando a expulsão da Via 0
        read_cache(8'h20, read_val, hit_status);
        check_assert("Expulsao forcada ocorreu com sucesso", hit_status == 0);
        
        // Tenta ler o endereço que foi expulso (deve puxar da memória o valor sujo atualizado)
        read_cache(8'h00, read_val, hit_status);
        check_assert("Write-back funcionou (memoria atualizada)", read_val == 32'h99999999 && hit_status == 0);
    endtask


    initial begin
        // Salva os arquivos 
        $dumpfile("tb_cache_waveforms.vcd");
        $dumpvars(0, tb_cache_top);

        // Zera tudo
        clk = 0; reset = 0; cpu_read = 0; cpu_write = 0; cpu_addr = 0; cpu_wdata = 0;
        #10;
        
        // Roda as tarefas
        test_edge_cases();
        test_consistency();
        test_replacement();

        // Print do resultado final
        $display("\n========================================");
        $display("Total executados: %0d", total_tests);
        $display("PASSARAM        : %0d", tests_passed);
        $display("FALHARAM        : %0d", tests_failed);
        $display("========================================");

        #50;
        $finish;
    end

endmodule