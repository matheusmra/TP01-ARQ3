module cache_controller (
    input  logic        clk,
    input  logic        reset,

    input  logic        cpu_read,
    input  logic        cpu_write,
    input  logic [7:0]  cpu_addr,
    input  logic [31:0] cpu_wdata,

    output logic [31:0] cpu_rdata,
    output logic        cpu_ready,
    output logic        cache_hit,

    output logic        mem_read,
    output logic        mem_write,
    output logic [7:0]  mem_addr,
    output logic [31:0] mem_wdata,
    input  logic [31:0] mem_rdata,
    input  logic        mem_ready
);

    // Parametros da cache
    localparam int NUM_SETS    = 4;
    localparam int NUM_WAYS    = 2;
    localparam int DATA_WIDTH  = 32;
    localparam int TAG_BITS    = 4;
    localparam int INDEX_BITS  = 2;

    // Mapeamento do endereco (8 bits)
    // [7:4] -> Tag
    // [3:2] -> Indice do Conjunto
    // [1:0] -> Byte Offset (ignorado para acesso por palavra)

    // Estados da FSM do Controlador
    typedef enum logic [2:0] {
        ST_IDLE,
        ST_COMPARE,
        ST_WB_REQ,
        ST_WB_WAIT,
        ST_FETCH_REQ,
        ST_FETCH_WAIT,
        ST_UPDATE,
        ST_FINISH
    } fsm_state_t;

    fsm_state_t state_reg, state_next;

    // Estruturas de armazenamento da cache
    logic                  valid_array [NUM_SETS][NUM_WAYS];
    logic                  dirty_array [NUM_SETS][NUM_WAYS];
    logic [TAG_BITS-1:0]   tag_array   [NUM_SETS][NUM_WAYS];
    logic [DATA_WIDTH-1:0] data_array  [NUM_SETS][NUM_WAYS];

    // LRU: 1 bit por set. 0 = via 0 e mais antiga, 1 = via 1 e mais antiga
    logic lru_bits [NUM_SETS];

    // Registradores para segurar os sinais da CPU
    logic        latched_hit;
    logic        latched_read;
    logic        latched_write;
    logic [7:0]  latched_addr;
    logic [31:0] latched_wdata;

    // Fios combinacionais para Tag e Indice
    logic [TAG_BITS-1:0]   curr_tag;
    logic [INDEX_BITS-1:0] curr_idx;

    assign curr_tag = latched_addr[7:4];
    assign curr_idx = latched_addr[3:2];

    // Logica de deteccao de Hit
    logic hit_w0;
    logic hit_w1;
    logic is_hit;
    logic target_hit_way;

    assign hit_w0 = valid_array[curr_idx][0] && (tag_array[curr_idx][0] == curr_tag);
    assign hit_w1 = valid_array[curr_idx][1] && (tag_array[curr_idx][1] == curr_tag);
    assign is_hit = hit_w0 || hit_w1;
    assign target_hit_way = hit_w1 ? 1'b1 : 1'b0;

    // Logica de substituicao (qual via ejetar?)
    logic way_to_evict;
    logic latched_way_to_evict;

    always_comb begin
        if (!valid_array[curr_idx][0]) begin
            way_to_evict = 1'b0; // Via 0 esta livre
        end else if (!valid_array[curr_idx][1]) begin
            way_to_evict = 1'b1; // Via 1 esta livre
        end else begin
            way_to_evict = lru_bits[curr_idx]; // Substitui baseada em LRU
        end
    end

    // FSM Logica de Proximo Estado e Saidas Combinacionais
    always_comb begin
        state_next = state_reg;

        cpu_ready = 1'b0;
        cache_hit = 1'b0;

        mem_read  = 1'b0;
        mem_write = 1'b0;
        mem_addr  = 8'b0;
        mem_wdata = 32'b0;

        case (state_reg)
            ST_IDLE: begin
                if (cpu_read || cpu_write) begin
                    state_next = ST_COMPARE;
                end
            end

            ST_COMPARE: begin
                if (is_hit) begin
                    state_next = ST_FINISH;
                end else if (valid_array[curr_idx][way_to_evict] && dirty_array[curr_idx][way_to_evict]) begin
                    // Miss em bloco modificado -> Write-back necessario
                    state_next = ST_WB_REQ;
                end else begin
                    // Miss em bloco limpo ou vazio -> Busca na memoria principal
                    state_next = ST_FETCH_REQ;
                end
            end

            ST_WB_REQ: begin
                mem_write = 1'b1;
                mem_addr  = {tag_array[curr_idx][latched_way_to_evict], curr_idx, 2'b00};
                mem_wdata = data_array[curr_idx][latched_way_to_evict];
                state_next = ST_WB_WAIT;
            end

            ST_WB_WAIT: begin
                if (mem_ready) begin
                    state_next = ST_FETCH_REQ;
                end
            end

            ST_FETCH_REQ: begin
                mem_read = 1'b1;
                mem_addr = {curr_tag, curr_idx, 2'b00};
                state_next = ST_FETCH_WAIT;
            end

            ST_FETCH_WAIT: begin
                mem_read = 1'b1;
                mem_addr = {curr_tag, curr_idx, 2'b00};

                if (mem_ready) begin
                    state_next = ST_UPDATE;
                end
            end

            ST_UPDATE: begin
                state_next = ST_FINISH;
            end

            ST_FINISH: begin
                cpu_ready = 1'b1;
                cache_hit = latched_hit;
                state_next = ST_IDLE;
            end

            default: begin
                state_next = ST_IDLE;
            end
        endcase
    end

    // FSM Atualizacao de Estado e Logica Sequencial (Datapath)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= ST_IDLE;

            cpu_rdata     <= 32'b0;
            latched_read  <= 1'b0;
            latched_write <= 1'b0;
            latched_addr  <= 8'b0;
            latched_wdata <= 32'b0;
            
            latched_way_to_evict <= 1'b0;
            latched_hit <= 1'b0;

            for (int i = 0; i < NUM_SETS; i++) begin
                lru_bits[i] <= 1'b0;
                for (int j = 0; j < NUM_WAYS; j++) begin
                    valid_array[i][j] <= 1'b0;
                    dirty_array[i][j] <= 1'b0;
                    tag_array[i][j]   <= {TAG_BITS{1'b0}};
                    data_array[i][j]  <= {DATA_WIDTH{1'b0}};
                end
            end
        end else begin
            state_reg <= state_next;

            case (state_reg)
                ST_IDLE: begin
                    if (cpu_read || cpu_write) begin
                        latched_read  <= cpu_read;
                        latched_write <= cpu_write;
                        latched_addr  <= cpu_addr;
                        latched_wdata <= cpu_wdata;
                    end
                end

                ST_COMPARE: begin
                    latched_hit <= is_hit;

                    if (is_hit) begin
                        if (latched_read) begin
                            cpu_rdata <= data_array[curr_idx][target_hit_way];
                        end

                        if (latched_write) begin
                            data_array[curr_idx][target_hit_way]  <= latched_wdata;
                            dirty_array[curr_idx][target_hit_way] <= 1'b1;
                            cpu_rdata <= latched_wdata;
                        end

                        lru_bits[curr_idx] <= ~target_hit_way; // Atualiza a LRU para a outra via
                    end else begin
                        latched_way_to_evict <= way_to_evict; // Salva quem vai sair
                    end
                end

                ST_FETCH_REQ: begin
                    // Sinais combinacionais sobem, sem logica sequencial aqui
                end

                ST_FETCH_WAIT: begin
                    // Aguardando memoria
                end

                ST_UPDATE: begin
                    valid_array[curr_idx][latched_way_to_evict] <= 1'b1;
                    tag_array[curr_idx][latched_way_to_evict]   <= curr_tag;

                    if (latched_read) begin
                        data_array[curr_idx][latched_way_to_evict]  <= mem_rdata;
                        dirty_array[curr_idx][latched_way_to_evict] <= 1'b0;
                        cpu_rdata <= mem_rdata;
                    end

                    if (latched_write) begin
                        data_array[curr_idx][latched_way_to_evict]  <= latched_wdata;
                        dirty_array[curr_idx][latched_way_to_evict] <= 1'b1;
                        cpu_rdata <= latched_wdata;
                    end

                    lru_bits[curr_idx] <= ~latched_way_to_evict; // Atualiza a LRU
                end

                default: begin
                    // Demais estados nao requerem datapath sequencial
                end
            endcase
        end
    end

endmodule
