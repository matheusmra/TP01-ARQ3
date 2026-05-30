module main_memory #(
    parameter int LATENCY = 5  // Número de ciclos para simular tempo de acesso
) (
    input  logic        clk,
    input  logic        reset,

    // Interface com o cache_controller 
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [7:0]  mem_addr,
    input  logic [31:0] mem_wdata,

    output logic [31:0] mem_rdata,
    output logic        mem_ready
);

    // -------------------------------------------------------------------------
    //  cada uma com 1 palavra de 32 bits
    // -------------------------------------------------------------------------
    logic [31:0] storage [0:255];

    // Contador de latência: 0 = inativo, >0 = contando
    int unsigned latency_counter;

    // Registra se a operação pendente é leitura ou escrita
    logic        pending_read;
    logic        pending_write;
    logic [7:0]  pending_addr;
    logic [31:0] pending_wdata;


    task automatic preload_storage();
        // Zera tudo primeiro
        for (int i = 0; i < 256; i++) begin
            storage[i] = 32'h0;
        end
        // Dados de teste: endereço * 0x11 (padrão fácil de identificar em waveform)
        for (int i = 0; i < 16; i++) begin
            storage[i] = 32'(i * 32'h11111111);
        end
        // Alguns valores fixos em endereços específicos para testes direcionados
        storage[8'hA0] = 32'hDEADBEEF;
        storage[8'hB0] = 32'hCAFEBABE;
        storage[8'hC0] = 32'h12345678;
        storage[8'hD0] = 32'hAABBCCDD;
    endtask


    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_rdata       <= 32'b0;
            mem_ready       <= 1'b0;
            latency_counter <= 0;
            pending_read    <= 1'b0;
            pending_write   <= 1'b0;
            pending_addr    <= 8'b0;
            pending_wdata   <= 32'b0;
            preload_storage();
        end else begin


            mem_ready <= 1'b0;


            if ((mem_read || mem_write) && latency_counter == 0) begin
                // Registra o pedido e começa a contar
                pending_read  <= mem_read;
                pending_write <= mem_write;
                pending_addr  <= mem_addr;
                pending_wdata <= mem_wdata;
                latency_counter <= LATENCY;
            end

            else if (latency_counter > 0) begin
                latency_counter <= latency_counter - 1;


                if (latency_counter == 1) begin
                    if (pending_read) begin
   
                        mem_rdata <= storage[pending_addr];
                    end
                    if (pending_write) begin

                        storage[pending_addr] <= pending_wdata;
                    end

                    mem_ready <= 1'b1;


                    pending_read  <= 1'b0;
                    pending_write <= 1'b0;
                end
            end

        end
    end

endmodule
