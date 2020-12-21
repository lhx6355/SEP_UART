`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/07 21:12:42
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module test();
    reg           pclk      ; //clock
    reg           pclkg     ;
    reg           prst_n    ; //reset
    reg           psel      ; 
    reg           penable   ;
    reg           pwrite    ;
    reg    [11:2] paddr     ;
    reg    [31:0] pwdata    ;
    wire          pready    ;    
    wire          pslverr   ;   
    reg    [31:0] prdata    ; 
    wire   [31:0] prdata1   ;
    wire   [31:0] prdata2   ;
    reg    [3: 0] ecorevnum ;

    wire           rxd      ;
    wire           txd      ;
    wire           txint    ;
    wire           txen     ;
    wire           baudtick ;
    wire           rxint    ;
    wire           uartint_flag;
    wire           uartint  ;
    wire           txovrint ;
    wire           rxovrint ;
    reg            rstn     ;


    wire           txint2   ;
    wire           txen2    ;
    wire           baudtick2;
    wire           rxint2   ;
    wire           uartint_flag2;
    wire           uartint2 ;
    wire           txovrint2;
    wire           rxovrint2;

    reg     [31:0] rdata    ;
    


    localparam Data_Value =       10'h000;
    localparam Tx_Rx_Status =     10'h001;  //
    localparam Control_Register = 10'h002;
    localparam interrupt =        10'h003;  //
    localparam Band_rate =        10'h004;
    localparam Parity_Check =     10'h005;

    localparam cont =             3;
    localparam bese =             10'h001 << cont;

    initial  begin
        pclk =   0;
        pclkg =  0;
        psel =   0;
        penable= 0;
        pwrite = 0;
        paddr  = 0;
        pwdata = 0;
        prdata = 0;
        ecorevnum = 0;  
        rdata = 0;
        prst_n = 1;
                #2
        prst_n = 0;
        #2
        prst_n = 1;


        
        APBsend(Control_Register,  7'h3f,   1);
        APBsend(Band_rate,        19'h10,   1);
        APBsend(Parity_Check,      7'h01,   1);

        APBsend(Control_Register + bese, 7'h3f,   1);
        APBsend(Band_rate + bese,        19'h10,   1);
        APBsend(Parity_Check + bese,      7'h01,   1);

        #1000
        APBsend(Data_Value,       8'h34,   1);
        APBsend(Data_Value + bese,       8'hcd,   1);
    end

    //生成72MHz波形, 实际71.429MHz
    always #7         pclk = ~pclk ;    
    always #224       pclkg = ~pclkg;

    
    first uart(
        .PCLK       (pclk), 
        .PCLKG      (pclk), 
        .PRESETn    (prst_n),
        .PSEL       (psel),
        .PADDR      (paddr),
        .PENABLE    (penable), 
        .PWRITE     (pwrite), 
        .PWDATA     (pwdata),
        .ECOREVNUM  (ecorevnum),
        .PRDATA     (prdata1),
        .PREADY     (pready),
        .PSLVERR    (pslverr),     
        
        .RXD            (rxd),
        .TXD            (txd),
        .TXEN           (txen),
        .BAUDTICK       (baudtick), 
        .clk_16m        (pclk), 
        .clk_16m_rstn   (prst_n),
        .TXINT          (txint),
        .RXINT          (rxint),
        .UARTINT_FLAG   (uartint_flag),
        .TXOVRINT       (txovrint),   
        .RXOVRINT       (rxovrint),
        .UARTINT        (uartint));

    second uart2(
        .PCLK       (pclk), 
        .PCLKG      (pclk), 
        .PRESETn    (prst_n),
        .PSEL       (psel),
        .PADDR      (paddr),
        .PENABLE    (penable), 
        .PWRITE     (pwrite), 
        .PWDATA     (pwdata),
        .ECOREVNUM  (ecorevnum),
        .PRDATA     (prdata2),
        .PREADY     (pready),
        .PSLVERR    (pslverr),     
        
        .RXD            (txd),
        .TXD            (rxd),
        .TXEN           (txen2),
        .BAUDTICK       (baudtick2), 
        .clk_16m        (pclk), 
        .clk_16m_rstn   (prst_n),
        .TXINT          (txint2),
        .RXINT          (rxint2),
        .UARTINT_FLAG   (uartint_flag2),
        .TXOVRINT       (txovrint2),   
        .RXOVRINT       (rxovrint2),
        .UARTINT        (uartint2));




task APBsend;
    input  [11:2]addr;
    input  [31:0]data;
    input          rw;
    begin
        @(posedge pclk)
        //#1      //??
        psel   = 1'b1 ;
        pwrite = rw;
        paddr  = addr;
        pwdata = data;
        @(posedge pclk)
        //#1
        penable = 1'b1;
        @(posedge pclk)
        //#1
        if (pwrite == 0) begin
            if(addr[cont + 2] == bese[cont])
                prdata = prdata2;
            else
                prdata = prdata1;
            rdata = prdata;
        end
        psel      = 'b0; 
        penable   = 'b0;
        paddr     = 'b0;
        pwdata    = 'b0;
        prdata    = 'b0;
    end
endtask  

endmodule
