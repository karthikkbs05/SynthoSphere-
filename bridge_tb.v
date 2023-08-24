`timescale 1ns / 1ps

module bridge_tb;
reg clk,arvalid,res_n;
reg [1:0]arburst;
reg [3:0]arlen;
reg [4:0]araddr;
wire arready;
wire [15:0]rdata;
wire rresp,rlast;
reg rready;
wire rvalid;

wire [2:0]PADDR;
//wire [15:0]PWDATA,
reg [15:0]PRDATA;
wire PWRITE,PENABLE,PSEL1,PSEL2,PSEL3,PSEL4;
reg PREADY;

bridge dut(clk,arvalid,res_n,arburst,arlen,araddr,arready,rdata,rresp,rlast,rready,rvalid,PADDR,PRDATA,PWRITE,PENABLE,PSEL1,PSEL2,PSEL3,PSEL4,PREADY);

always #5 clk = ~clk;
initial
  begin
    clk = 0;
    res_n = 0;
    arvalid = 0;
    arburst = 2'b00;
    arlen = 0;
    araddr = 0;
    rready = 0;
    PRDATA = 0; 
    PREADY = 0; 
  end

initial 
  begin
    #5;
    #10 res_n = 1;
    #10;
    #10 arvalid = 1;arburst = 2'b01; arlen =4'b0011; araddr = 5'd9;
    #10;
    #10 arvalid =0;
    #10 PREADY = 1;PRDATA = 16'd10;
    #10;
    #10 PRDATA = 16'd17;
    #10;
    #10 PRDATA = 16'd25;
    #10;
    #10 PRDATA = 16'd30;
    #10;
    #10 PREADY = 0;
    #10 rready = 1;
    #10;
    #20;
    #20;
    #20;
    #20;
    $finish;
    
  end
endmodule
