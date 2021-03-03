# AdderNet-FPGA
1. AdderNet: https://github.com/huawei-noah/AdderNet
2. This project shows a demonstration on how many logic resources that AdderNet can save compared to a CNN.
3. We provide the implementation of 8-bit convolution network with 256 parallelism (parallelism of the input channel and the output channel are both 16). 
4. The macro definition of "AdderNet" in "conv_defines.vh" is to define the network to be Adder-conv or Multilpier-conv.


# Requirement
The software Xilinx Vivado 2018.1 (or later) and license can be downloaded in 
https://xilinx.com/products/design-tools/vivado.html

hardware platform should be: Zynq UltraScale+ ZCU102/104/106


# Quick Start
1. Download the project and then Unzip it.
2. Double click the AdderNet.xpr
3. Run simulation and implementation.
4. Note, it is a traditional 8bit-CNN if the macro definition (AdderNet) in "conv_defines.vh" is commented out, else it is 8-bit AdderNet.

# Result
The 8-bit Multilpier-conv needs 20493 LUT.
While the 8-bit Adder-conv needs only 7065 LUT, corresponding to 65.5%-off.
The result can be even better in higher parallelism and larger datawidth.
