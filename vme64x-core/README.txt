
==================================================
vme64x-core project
--------------------------------------------------
Matthieu Cattin
01.06.2012
==================================================

1) Directory structure

|-- documentation
|   |-- references
|   |-- specifications
|   `-- user_guides
|-- hdl
|   |-- boards               -> Board specific stuff
|   |   |-- svec             -> Board's directory, put the .ucf here
|   |   |   |-- ip_cores     -> Board specific generated IP cores (e.g. FIFO, RAM, etc...)
|   |   |   |-- rtl          -> Board specific RTL HDL sources (top level, specific blocks, etc..)
|   |   |   |-- sim          -> Board level simulation (testbenches, simulation scripts, etc...)
|   |   |   |-- syn          -> Synthesis directory (ISE project, chipscope files)
|   |   |   `-- wb_gen       -> Wishbone generator source files
|   |   `-- vfc              -> Board specific stuff
|   |       |-- ip_cores     -> Board's directory, put the .ucf here
|   |       |-- rtl          -> Board specific RTL HDL sources (top level, specific blocks, etc..)
|   |       |-- sim          -> Board level simulation (testbenches, simulation scripts, etc...)
|   |       |-- syn          -> Synthesis directory (ISE project, chipscope files)
|   |       `-- wb_gen       -> Wishbone generator source files
|   `-- vme64x-core          -> Core's dircetory
|       |-- ip_cores         -> Core generated IP cores (e.g. FIFO, RAM, etc...)
|       |-- rtl              -> Core RTL HDL sources (core top level, core sub-blocks, packages, etc...)
|       |-- sim              -> Core simulation (testbenches, simulation scripts, etc...)
|       `-- wb_gen           -> Wishbone generator source files
`-- sw                       -> Software directory
    `-- vfc                  -> Board specific software
        `-- python           -> Python programs

