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
--- hi 

