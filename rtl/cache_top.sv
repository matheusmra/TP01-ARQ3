module cache_top #(
    parameter int MEM_LATENCY = 5  // Repassado para a main_memory
) (
    input  logic        clk,
    input  logic        reset,

    // Interface da CPU (exposta para os testbenches)
    input  logic        cpu_read,
    input  logic        cpu_write,
    input  logic [7:0]  cpu_addr,
    input  logic [31:0] cpu_wdata,

    output logic [31:0] cpu_rdata,
    output logic        cpu_ready,
    output logic        cache_hit
);


    logic        mem_read;
    logic        mem_write;
    logic [7:0]  mem_addr;
    logic [31:0] mem_wdata;
    logic [31:0] mem_rdata;
    logic        mem_ready;


    cache_controller ctrl (
        .clk        (clk),
        .reset      (reset),

        // Lado da CPU
        .cpu_read   (cpu_read),
        .cpu_write  (cpu_write),
        .cpu_addr   (cpu_addr),
        .cpu_wdata  (cpu_wdata),
        .cpu_rdata  (cpu_rdata),
        .cpu_ready  (cpu_ready),
        .cache_hit  (cache_hit),

        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_rdata  (mem_rdata),
        .mem_ready  (mem_ready)
    );


    main_memory #(
        .LATENCY    (MEM_LATENCY)
    ) mem (
        .clk        (clk),
        .reset      (reset),


        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_rdata  (mem_rdata),
        .mem_ready  (mem_ready)
    );

endmodule
