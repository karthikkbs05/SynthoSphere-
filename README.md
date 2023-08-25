## SynthoSphere-
Designing a Digital Circuit and performing pre and post synthesis simulation. 


# APB Bridge based on AMBA AXI 4.0-

## Designing and Testing an APB to AXI Bridge which does Read operation where the Master uses AXI protocol and the Slaves use APB protocol-

This project focuses on creating a simplified bridge that facilitates read transactions from APB peripherals, offering enhanced understandability by utilizing a streamlined set of signals.



## Application of the Bridge-
* Protocol Integration: Bridges communication gaps between components using different protocols, such as connecting AXI and APB modules
* Software Development: Simplifies software coding when AXI processors interact with APB peripherals by abstracting protocol differences
* Interfacing Standard Peripherals: Enables AXI-based systems to connect with peripherals that support only the APB protocol
* Design Simplification: Reduces complexity by offering pre-designed solutions for protocol conversion


## Block diagram-
![download](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/63491d39-3d3e-44f6-b5ed-d0d726e7e09a)

From the Block Diagram we observe that the Bridge has:
* AXI Slave Interface
* APB Master Interface




## APB Master-
![2-Figure4-1](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/6c0c0cd9-96d5-4537-8885-eb3771a4b52c)
## APB Master Read Operation-
![amba-3-apb-5](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/b8111c79-7ced-4061-8200-3b76d21ffa37)


## AXI Slave (Read Operation)-
![Screenshot (224)](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/ba0cab30-f121-49a6-9121-3cc46f32f1f7)
![Screenshot (225)](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/be9d808d-f62d-4b73-9f81-4ee668e32b59)

We combine both APB master and AXI slave to design the bridge
## Verilog RTL code-
Here in this design 'arsize' signal of the AXI Slave Interface is not used.
```
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
```
## Pre-Synthesis Simulation using Iverilog-
In the terminal:
```
iverilog bridge.v bridge_tb.v
./a.out
gtkwave bridge.vcd
```
In the GTKWAVE waveform viewer:
![presynth](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/f32cf25b-3965-493a-a5e5-852949e2149c)

## Synthesis using Yosys-
In the terminal :
```
yosys
```
Yosys script (executed line by line) :
```
read_liberty -lib ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog bridge.v
synth -top bridge
dfflibmap -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
abc -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
show bridge
write_verilog -noattr netlist_bridge.v
exit
```
### Synthesis Statistics-
![statictics](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/12a27ce2-716f-4f20-b705-c81951558075)

### Cells Mapped during Synthesis-
![mapped](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/74235dae-fd9f-41b4-9b89-35373587f8da)

### Synthesized Netlist view-

![synth1](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/162e0ea6-c8b1-4104-843c-5de31cf82810)
![synth2](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/9d7bd266-c0cf-4d9c-8331-0916f81924db)
![synth3](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/f3420673-0c55-458b-b019-5eb9169725a2)
![synth4](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/e31c9cbe-db26-412a-9278-475681a21fbd)
![synth5](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/394bf9b2-436f-42d1-82f5-762e8bab9407)

For more closer look :
* https://github.com/karthikkbs05/SynthoSphere-/tree/main/synthesis%20netlist%20image

## Post-Synthesis Simulation-
### Error Occured-
The '$_DLATCH_P_' in the did not get mapped to any cells during synthesis
![error_mes](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/f1f1a732-e56c-4662-8cb5-7944d777d464)

![error_dflop](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/c77434ee-b091-4b0a-ad4b-57c227024bec)

### Rectification Trial 1-
* Tried mapping '$_DLATCH_P_' manually to 'sky130_fd_sc_hd__dlrtn' which is present in the library file
* Signal 'E'(actice high) had to replaced with 'GATE_N'(active low)
* 'sky130_fd_sc_hd__dlrtn' module had 'RESET_B' signal, hence '.RESET_B(res_n)' was added.
  
![Screenshot from 2023-08-25 21-20-03](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/a173b199-60c9-49f8-bd9a-11ec6f39046c)


Rectified part of the netlist :


![Screenshot from 2023-08-26 00-26-17](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/33f5a6d7-3243-4528-bc71-71b93a2e642b)

### Rectification Trial 1 failed-
Error in Post-Synthesis simulation
![Screenshot from 2023-08-26 00-23-53](https://github.com/karthikkbs05/SynthoSphere-/assets/129792064/5515d609-a454-407c-9f4c-9061e49d0bee)

