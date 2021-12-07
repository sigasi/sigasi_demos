# EL2 SweRV RISC-V Core<sup>TM</sup> 1.4 from Western Digital

This repository contains the EL2 RISC-V SweRV Core<sup>TM</sup>  design RTL

## License

By contributing to this project, you agree that your contribution is governed by [Apache-2.0](LICENSE).  
Files under the [tools](tools/) directory may be available under a different license. Please review individual file for details.

## Directory Structure

    ├── configs                 # Configurations Dir
    │   └── snapshots           # Where generated configuration files are created
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
        ├── hex                 #   Canned demo hex files
        └── tests               #   Example tests
 
## Dependencies

- Verilator **(4.102 or later)** must be installed on the system if running with verilator
- If adding/removing instructions, espresso must be installed (used by *tools/coredecode*)
- RISCV tool chain (based on gcc version 8.3 or higher) must be
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

This will update the **default** snapshot in ./snapshots/default/ with parameters for a 64K DCCM.  

Add `-snapshot=dccm64`, for example, if you wish to name your build snapshot *dccm64* and refer to it during the build.  

There are 4 predefined target configurations: `default`, `default_ahb`, `typical_pd` and `high_perf` that can be selected via 
the `-target=name` option to swerv.config. **Note:** that the `typical_pd` target is what we base our published PPA numbers. It does not include an ICCM.

**Building an FPGA speed optimized model:**
Use ``-fpga_optimize=1`` option to ``swerv.config`` to build a model that removes clock gating logic from flop model so that the FPGA builds can run at higher speeds. **This is now the default option for
targets other than ``typical_pd``.**

**Building a Power optimized model (ASIC flows):**
Use ``-fpga_optimize=0`` option to ``swerv.config`` to build a model that **enables** clock gating logic into the flop model so that the ASIC flows get a better power footprint. **This is now the default option for
target``typical_pd``.**

This script derives the following consistent set of include files :  

    ./snapshots/default
    ├── common_defines.vh                       # `defines for testbench or design
    ├── defines.h                               # #defines for C/assembly headers
    ├── el2_param.vh                            # Design parameters
    ├── el2_pdef.vh                             # Parameter structure
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

     
    `$RV_ROOT/configs/swerv.config [configuration options..] -snapshot=mybuild`  
    
    Snapshots are placed in ./snapshots directory


1. Running a simple Hello World program (verilator)

    `make -f $RV_ROOT/tools/Makefile`

This command will build a verilator model of SweRV EL2 with AXI bus, and
execute a short sequence of instructions that writes out "HELLO WORLD"
to the bus.

    
The simulation produces output on the screen like: u 
```

VerilatorTB: Start of sim

----------------------------------
Hello World from SweRV EL2 @WDC !!
----------------------------------
TEST_PASSED

Finished : minstret = 437, mcycle = 922
See "exec.log" for execution trace with register updates..

```
The simulation generates following files:

 `console.log` contains what the cpu writes to the console address of 0xd0580000.  
 `exec.log` shows instruction trace with GPR updates.  
 `trace_port.csv` contains a log of the trace port.  
 When `debug=1` is provided, a vcd file `sim.vcd` is created and can be browsed by 
  gtkwave or similar waveform viewers.
  
You can re-execute simulation using:  
    `make -f $RV_ROOT/tools/Makefile verilator`


  
The simulation run/build command has following generic form:

    make -f $RV_ROOT/tools/Makefile [<simulator>] [debug=1] [snapshot=mybuild] [target=<target>] [TEST=<test>] [TEST_DIR=<path_to_test_dir>]

where:
``` 
<simulator> -  can be 'verilator' (by default) 'irun' - Cadence xrun, 'vcs' - Synopsys VCS, 'vlog' Mentor Questa
               'riviera'- Aldec Riviera-PRO. if not provided, 'make' cleans work directory, builds verilator executable and runs a test.
debug=1     -  allows VCD generation for verilator and VCS and SHM waves for irun option.
<target>    -  predefined CPU configurations 'default' ( by default), 'default_ahb', 'typical_pd', 'high_perf' 
TEST        -  allows to run a C (<test>.c) or assembly (<test>.s) test, hello_world is run by default 
TEST_DIR    -  alternative to test source directory testbench/asm or testbench/tests
<snapshot>  -  run and build executable model of custom CPU configuration, remember to provide 'snapshot' argument 
               for runs on custom configurations.
CONF_PARAMS -  allows to provide -set options to swerv.conf script to alter predefined EL2 targets parameters
```
Example:
     
    make -f $RV_ROOT/tools/Makefile verilator TEST=cmark

will build and simulate  testbench/asm/cmark.c program with verilator 


If you want to compile a test only, you can run:

    make -f $RV_ROOT/tools/Makefile program.hex TEST=<test> [TEST_DIR=/path/to/dir]


The Makefile uses  `snapshot/<target>/link.ld` file, generated by swerv.conf script by default to build test executable.
User can provide test specific linker file in form `<test_name>.ld` to build the test executable,
in the same directory with the test source.

User also can create a test specific makefile in form `<test_name>.makefile`, containing building instructions
how to create `program.hex` file used by simulation. The private makefile should be in the same directory
as the test source. See examples in `testbench/asm` directory.

Another way to alter test building process is to use `<test_name>.mki` file in test source directory. It may help to select multiple sources
to compile and/or alter compilation swiches. See examples in `testbench/tests/` directory
 
*(`program.hex` file is loaded to instruction and LSU bus memory slaves and
optionally to DCCM/ICCM at the beginning of simulation)*.

User can build `program.hex` file by any other means and then run simulation with following command:

    make -f $RV_ROOT/tools/Makefile <simulator>

Note: You may need to delete `program.hex` file from work directory, when run a new test.

The  `$RV_ROOT/testbench/asm` directory contains following tests ready to simulate:
```
hello_world       - default test program to run, prints Hello World message to screen and console.log
hello_world_dccm  - the same as above, but takes the string from preloaded DCCM.
hello_world_iccm  - the same as hello_world, but loads the test code to ICCM via LSU to DMA bridge and then executes
                    it from there. Runs on EL2 with AXI4 buses only. 
cmark             - coremark benchmark running with code and data in external memories
cmark_dccm        - the same as above, running data and stack from DCCM (faster)
cmark_iccm        - the same as above with preloaded code to ICCM (slower, optimized for size to fit into default ICCM). 

dhry              - Run dhrystone. (Scale by 1757 to get DMIPS/MHZ)
```

The `$RV_ROOT/testbench/hex` directory contains precompiled hex files of the tests, ready for simulation in case RISCV SW tools are not installed.

**Note**: The testbench has a simple synthesizable bridge that allows you to load the ICCM via load/store instructions. This is only supported for AXI4 builds.



----
Western Digital, the Western Digital logo, G-Technology, SanDisk, Tegile, Upthere, WD, SweRV Core, SweRV ISS, 
and OmniXtend are registered trademarks or trademarks of Western Digital Corporation or its affiliates in the US 
and/or other countries. All other marks are the property of their respective owners.
