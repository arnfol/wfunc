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

