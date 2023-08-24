`timescale 1ns / 1ps

module bridge(
input clk,arvalid,res_n,
input [1:0]arburst,
//input [2:0]arsize,
input [3:0]arlen,
input [4:0]araddr,
output arready,
output reg [15:0]rdata,
output rresp,rlast,
input rready,
output rvalid,

//input PCLK,
output [2:0]PADDR,
//output [15:0]PWDATA,
input [15:0]PRDATA,
output PWRITE,PENABLE,PSEL1,PSEL2,PSEL3,PSEL4,
input PREADY
    );
    
    parameter IDLE = 3'b000,SETUP_M = 3'b001,SETUP_S = 3'b010,
              ACCESS_S = 3'b011,PREACCESS_M = 3'b100,ACCESS_M = 3'b101;
    reg [2:0]current_state,next_state=IDLE;
    reg [1:0]DWREQ = 0;
    reg [12:0]burst;
    reg [3:0]lenS;
    reg [3:0]lenM;
    reg [4:0]addr;
    reg [15:0]DDATA[15:0];
    reg [2:0]DADDR = 0;
    integer i = 0;
    reg last;
    
//    initial
//      begin
//        DDATA[0] = 16'h00;
//        DDATA[1] = 16'h00;
//        DDATA[2] = 16'h00;
//        DDATA[3] = 16'h00;
//        DDATA[4] = 16'h00;
//        DDATA[5] = 16'h00;
//        DDATA[6] = 16'h00;
//      end 
    
    always@(posedge clk,negedge res_n)
    begin
      if(!res_n)
        current_state <= IDLE;
      else 
        current_state <= next_state;
    end
    
    
    always@(arvalid,current_state,rready,PREADY)
    begin
      case(current_state)
        IDLE : begin
                 i = 0;
                 last = 0;
                 rdata = 0;
                 if(arvalid)
                   begin
                     next_state <= SETUP_M; 
                     DWREQ = 2'b01;
                   end
                 else
                     next_state <=IDLE;   
               end
        SETUP_M : begin
                    addr = araddr;
                    burst = arburst;
                    lenS = arlen; 
                    lenM = arlen + 1;
                    //address translation
                    DADDR = addr % 8;
                    next_state <= SETUP_S;                   
                  end
        
        SETUP_S : begin
                    if(PREADY)
                      begin
                        DDATA[i] = PRDATA;
                        next_state <= ACCESS_S;
                      end 
                    else 
                      next_state <= SETUP_S;
                  end  
                  
        ACCESS_S : begin
                     if(lenS != 0)
                       begin
                         case(burst)
                         2'b00 : DADDR = DADDR;
                         2'b01 : DADDR = DADDR + 1;
                         endcase 
                       lenS = lenS - 1;
                       i = i + 1;
                       next_state <= SETUP_S; 
                       end
                     else 
                       next_state <= PREACCESS_M;
                   end
                   
        PREACCESS_M : begin
                        if(rready)
                          next_state <= ACCESS_M;
                        else 
                          next_state <= PREACCESS_M; 
                      end 
                      
        ACCESS_M : begin
                     if(lenM != 0)
                       begin
                         next_state <= PREACCESS_M;
                         if(lenM == 4'd1)
                           begin
                             last = 1;
                             next_state <= IDLE;
                           end
                         rdata = DDATA[i];
                         i = i - 1;
                         lenM = lenM - 1;
                       end
                     else 
                       next_state <= IDLE;
                   end
      endcase 
    end
    
    assign arready = (current_state == SETUP_M);
    assign PADDR = DWREQ[0] ? DADDR : 3'd0;
    assign PSEL1 = (current_state == SETUP_M || current_state == SETUP_S || current_state == ACCESS_S)?((addr >= 5'b00000 && addr <= 5'b00111) ? 1 : 0) : 0;
    assign PSEL2 = (current_state == SETUP_M || current_state == SETUP_S || current_state == ACCESS_S)?((addr >= 5'b01000 && addr <= 5'b01111) ? 1 : 0) : 0;
    assign PSEL3 = (current_state == SETUP_M || current_state == SETUP_S || current_state == ACCESS_S)?((addr >= 5'b10000 && addr <= 5'b10111) ? 1 : 0) : 0;
    assign PSEL4 = (current_state == SETUP_M || current_state == SETUP_S || current_state == ACCESS_S)?((addr >= 5'b11000 && addr <= 5'b11111) ? 1 : 0) : 0;
    assign PWRITE = (DWREQ[1] && (PSEL1 || PSEL2 || PSEL3 || PSEL4));
    assign PENABLE = (current_state == SETUP_S || current_state == ACCESS_S);
    assign rresp = (current_state == ACCESS_M);
    assign rlast = (rresp && last);
    assign rvalid = (current_state == ACCESS_M);
    
endmodule
