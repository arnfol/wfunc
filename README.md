# Project description #
Project consist of RTL code and testing environment for window function IP core. Originally this code was a part of Fast Fourier Transform (FFT) project. 

IP core had AXI-Stream compatible interfaces for data path and simplified AMBA APB interface for configuration and control. All math is done with 32 bit complex numbers (consist of 16 bits for real and 16 bits for imaginary part). Output data width is doubled - 32 bits for each part, real and imaginary, resulting in 64 bits for each complex number.

AXI-Stream buses width is configurable through parameter and supports 2, 4 or 8 (larger values were not tested).

IP core also has simple state machine to control data flow and configuration.

## Features ##
* AXI-Stream data interfaces.
* AMBA APB control interface.
* Configurable data width.
* Block memory for window samples storage.
* Pipelined math with additional registers for retiming.
* 32-bit complex math.

## Testing environment ##
Provided test environment is a bit messy, but is designed to support automated runs for all possible configurations of IP core. All testing was done with _ModelSim ALTERA STARTER EDITION 10.5b 2016.10_ and _Python 3.6.6_ (probably script could work with earlier versions of Python).

Testing works in the following way: firstly, the python script makes input files for verilog testbench and reference file with results. Thereafter script calls modelsim and pass configuration parameters to it. Eventually, testbench generates it own output file with results and python script compares this file with reference file.

# APB registers map #

Registers are given in a following format: 
## \<ADDRESS> : \<REG NAME> ##
\<DESCRIPTION>

Each register is aligned to 32-bit word bounds, which means 2 least significant bits 
of paddr bus should always be zeros.

## x0000 - [(FFT_SIZE-1)*4] : Window values ##

| BITS       | ACCESS  | RST VALUE  | DESCRIPTION                     |
|------------|---------|------------|---------------------------------|
| 31-16      |  RW     |  xXXXX     | Imaginary part of window sample |
| 15-0       |  RW     |  xXXXX     | Real part of window sample      |

**Note:** If parameter APB_A_REV=1, address of these registers is bit-reverted.
For instance, if FFT_SIZE=8192 and you are writing to address x0004, you will 
access x4000 instead. This was done to simplify work with reverted-order 
packets after FFT.

## [FFT_SIZE*4] : Control register ##

| BITS       | ACCESS  | RST VALUE  | DESCRIPTION                                        |
|------------|---------|------------|----------------------------------------------------|
| 31-9       |  RO     |  x000000   | Unused                                             |
| 8          |  WO     |  -         | Writing 1 executes command "CHANGE STATE"          |
| 7-1        |  RO     |  x00       | Unused                                             |
| 0          |  WO     |  -         | FSM reset. Writing 1 puts FSM into IDLE state      |

## [(FFT_SIZE+1)*4] : Status register ##

| BITS       | ACCESS  | RST VALUE  | DESCRIPTION                                        |
|------------|---------|------------|----------------------------------------------------|
| 31-10      |  RO     |  x000000   | Unused                                             |
| 9-8        |  RO     |  x0        | FSM state. IDLE=x0, WAIT=x1, BUSY=x2.              |
| 7-0        |  RO     |  x00       | Unused                                             |

# FSM #
## State diagram ##

    IDLE -1-> WAIT -2-> BUSY -5-> WAIT
                   -3-> IDLE

## State description ##
**Note:** In any state write 1 to FSM reset register puts FSM into IDLE state.
### IDLE ###
In this state module does nothing. You can access and configure all registers. After
receiving "CHANGE STATE" command FSM moves to WAIT state (1).
### WAIT ###
In this state module is waiting for new packet on AXI-Stream line. You cannot access
window registers (address x0000-[(FFT_SIZE-1)*4]) in this state. Reception of a new 
AXIS packet moves FSM to BUSY state (2), otherwise "CHANGE STATE" command moves FSM 
to IDLE (3).
### BUSY ###
In BUSY state module handles packet. You also cannot access window registers (address 
x0000-[(FFT_SIZE-1)*4]). After reception of TLAST FSM goes  to WAIT state (5).
