# EH2 SweRV RISC-V Core<sup>TM</sup> 1.4 from Western Digital

This repository contains the EH2 RISC-V SweRV Core<sup>TM</sup>  design RTL

## Overview
SweRV EH2 is a machine-mode (M-mode) only, 32-bit CPU core which supports RISC-V’s integer (I), compressed instruction (C), multiplication and division (M), atomic (A), and instruction-fetch fence, CSR, and subset of bit manipulation instructions (Zb*) extensions. The core is a 9-stage, **dual-threaded**, dual-issue, superscalar, mostly in-order pipeline with some out-of-order execution capability. Please see the [PRM](docs/RISC-V_SweRV_EH2_PRM.pdf) for more details.

## License

By contributing to this project, you agree that your contribution is governed by [Apache-2.0](LICENSE).  
Files under the [tools](tools/) directory may be available under a different license. Please review individual file for details.

## Directory Structure

    ├── configs                 # Configurations Dir
    ├── design                  # Design root dir
    │   ├── dbg                 #   Debugger
    │   ├── dec                 #   Decode, Registers and Exceptions
    │   ├── dmi                 #   DMI block
    │   ├── exu                 #   EXU (ALU/MUL/DIV)
    │   ├── ifu                 #   Fetch & Branch Prediction
    │   ├── include             
    │   ├── lib
    │   └── lsu                 #   Load/Store
    ├── docs
    ├── tools                   # Scripts/Makefiles
    └── testbench               # (Very) simple testbench
        ├── asm                 #   Example assembly files
        └── hex                 #   Canned demo hex files
 
## Dependencies

- Verilator **(4.102 or later)** must be installed on the system if running with verilator
- If adding/removing instructions, espresso must be installed (used by *tools/coredecode*)
- RISCV tool chain (based on gcc version 7.3 or higher) must be
installed so that it can be used to prepare RISCV binaries to run.

## Quickstart guide
1. Clone the repository
1. Setup RV_ROOT to point to the path in your local filesystem
1. Determine your configuration {optional}
1. Run make with tools/Makefile

## Release Notes for this version
Please see [release notes](release-notes.md) for changes and bug fixes in this version of SweRV

### Configurations

SweRV can be configured by running the `$RV_ROOT/configs/swerv.config` script:

`% $RV_ROOT/configs/swerv.config -h` for detailed help options

For example to build with a DCCM of size 64 Kb:  

`% $RV_ROOT/configs/swerv.config -dccm_size=64`  

This will update the **default** snapshot in $PWD/snapshots/default/ with parameters for a 64K DCCM.  

Add `-snapshot=dccm64`, for example, if you wish to name your build snapshot *dccm64* and refer to it during the build.  

There are 4 predefined target configurations: `default`, `default_mt`, `typical_pd` and `high_perf` that can be selected via 
the `-target=name` option to swerv.config. See [configs/README.md](configs/README.md) for a description of these targets.

**Building an FPGA speed optimized model:**
Use ``-fpga_optimize=1`` option to ``swerv.config`` to build a model that removes clock gating logic from flop model so that the FPGA builds can run at higher speeds. **This is now the default option for
targets other than ``typical_pd``.**

**Building a Power optimized model (ASIC flows):**
Use ``-fpga_optimize=0`` option to ``swerv.config`` to build a model that **enables** clock gating logic into the flop model so that the ASIC flows get a better power footprint. **This is now the default option for
target``typical_pd``.**


This script derives the following consistent set of include files :  

    $PWD/snapshots/<snapshot_name>
    ├── common_defines.vh                       # `defines for testbench or design
    ├── defines.h                               # #defines for C/assembly headers
    ├── eh2_param.vh                            # Design parameters
    ├── eh2_pdef.vh                             # Parameter structure
    ├── pd_defines.vh                           # `defines for physical design
    ├── perl_configs.pl                         # Perl %configs hash for scripting
    ├── pic_map_auto.h                          # PIC memory map based on configure size
    └── whisper.json                            # JSON file for swerv-iss
    └── link.ld                                 # default linker control file



### Building a model

While in a work directory:

1. Set the RV_ROOT environment variable to the root of the SweRV directory structure.
Example for bash shell:  
    `export RV_ROOT=/path/to/swerv`  
Example for csh or its derivatives:  
    `setenv RV_ROOT /path/to/swerv`
    
1. Create your specific configuration

    *(Skip if default is sufficient)*  
    *(Name your snapshot to distinguish it from the default. Without an explicit name, it will update/override the __default__ snapshot)* 
    For example if `mybuild` is the name for the snapshot:

    set BUILD_PATH environment variable:
    
    `setenv BUILD_PATH snapshots/mybuild`
     
    `$RV_ROOT/configs/swerv.config [configuration options..] -snapshot=mybuild`  
    
    Snapshots are placed in `$BUILD_PATH` directory


1. Running a simple Hello World program (verilator)

    `make -f $RV_ROOT/tools/Makefile target=default_mt`

This command will build a verilator model of SweRV EH2 with AXI bus, and
execute a short sequence of instructions that writes out "HELLO WORLD"
to the bus.

    
The simulation produces output on the screen like:  

```
VerilatorTB: Start of sim

----------------------------------------
Hello World from SweRV EH2 hart0 @WDC !!
----------------------------------------
----------------------------------------
Hello World from SweRV EH2 hart1 @WDC !!
----------------------------------------
TEST_PASSED

Finished hart0 : minstret = 1158, mcycle = 2895
Finished hart1 : minstret = 1733, mcycle = 2822
See "exec.log" for execution trace with register updates..
```

The simulation generates following files:

 `console.log` contains what the cpu writes to the console address of 0xd0580000.  
 `exec.log` shows instruction trace with GPR updates.  
 `trace_port.csv` contains a log of the trace port.   
 When `debug=1` is provided, a vcd file `sim.vcd` is created and can be browsed by 
  gtkwave or similar waveform viewers.
  
You can re-execute simulation using:  
   ` ./obj_dir/Vtb_top `  
or  
    `make -f $RV_ROOT/tools/Makefile verilator`


  
The simulation run/build command has following generic form:

    make -f $RV_ROOT/tools/Makefile [<simulator>] [debug=1] [snapshot=<snap>] [target=<target>] [TEST=<test>] [TEST_DIR=<path_to_test_dir>][CONF_PARAMS=<conf_switches>]

where:
```
<simulator> -  can be 'verilator' (by default) 'irun' - Cadence xrun, 'vcs' - Synopsys VCS, 'vlog' - Mentor Questa
               if not provided, 'make' cleans work directory, builds verilator executable and runs a test.
debug=1     -  allows VCD generation for verilator and VCS and SHM waves for irun option.
<target>    -  predefined CPU configurations 'default' ( by default), 'default_mt', 'typical_pd', 'high_perf' 
TEST        -  allows to run a C (<test>.c) or assembly (<test>.s) test, hello_world is run by default 
TEST_DIR    -  alternative to test source directory testbench/asm
<snap>      -  run and build executable model of custom CPU configuration, remember to provide 'snapshot' argument 
               for runs on custom configurations.
CONF_PARAMS -  allows to provide swerv.config command line arguments like -set=dccm_size=32 or -unset=iccm_enable..
```
Example:
     
    make -f $RV_ROOT/tools/Makefile verilator TEST=cmark

will simulate  testbench/asm/cmark.c program with verilator on default target


If you want to compile a test only, you can run:

    make -f $RV_ROOT/tools/Makefile program.hex TEST=<test> [TEST_DIR=/path/to/dir]


The Makefile uses  `$RV_ROOT/testbench/linker.ld` file by default to build test executable.  
User can provide test specific linker file in form `<test_name>.ld` to build the test executable,
 in the same directory with the test source.

User also can create a test specific makefile in form `<test_name>.makefile`, contaning building instructions
how to create `program.hex`  files used by simulation. The private makefile should be in the same directory
as the test source.  
*(`program.hex` file is loaded to instruction and data bus memory slaves  and
optionally to DCCM/ICCM at the beginning of simulation)*.

Note: You may need to delete `program.hex` file from work directory, before running a new test.

The  `$RV_ROOT/testbench/asm` directory contains following tests ready to simulate:
```
hello_world       - default tes to run, prints Hello World message to screen and console.log
hello_world_dccm  - the same as above, but takes the string from preloaded DCCM.
hello_world_iccm  - the same as hello_world, but loads ICCM via LSU-DMA bridge and then executes from ICCM
cmark             - coremark benchmark running with code and data in external memories
cmark_dccm        - the same as above, running data and stack from DCCM (faster)
cmark_iccm        - the same as above, but preloading and running from ICCM 
cmark_mt          - coremark benchmark running with code and data in external memories for MT configs
cmark_dccm_mt     - the same as above, running data and stack from DCCM (faster) for MT configs
cmark_iccm_mt     - the same as above, but preloading and running from ICCM for MT configs
dhry              - dhrystone benchmark as example of multisouce program from testbench/tests/dhry directory
dhry_mt           - similar to above, but running two harts ( need to be run on MT configs )
```

The `$RV_ROOT/testbench/hex` directory contains precompiled hex files of the tests, ready for simulation in case RISCV SW tools are not installed.

**Note**: The testbench has a simple synthesizable bridge that allows you to load the ICCM via load/store instructions. This is only supported for AXI4 builds.

----
Western Digital, the Western Digital logo, G-Technology, SanDisk, Tegile, Upthere, WD, SweRV Core, SweRV ISS, 
and OmniXtend are registered trademarks or trademarks of Western Digital Corporation or its affiliates in the US 
and/or other countries. All other marks are the property of their respective owners.
