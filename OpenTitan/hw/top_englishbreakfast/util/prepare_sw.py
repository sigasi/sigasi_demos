#!/usr/bin/env python3
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
r"""Script to prepare SW for non-earlgrey tops
"""

import sys
import subprocess
import re
from pathlib import Path


def main():

    # Config
    name_old = 'earlgrey'
    name = 'englishbreakfast'

    topname = 'top_' + name

    path_root = str(Path(__file__).resolve().parents[3])

    # We start by removing any previously generated auto-gen files for the
    # selected non-earlgrey top. These might be stale and confuse topgen.
    cmd = [path_root + '/hw/' + topname + '/util/remove_autogen_files.sh']

    try:
        print("Removing auto-generated files...")
        subprocess.run(cmd,
                       check=True,
                       stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT,
                       universal_newlines=True)

    except subprocess.CalledProcessError as e:
        print("Removing auto-generated files failed: " + str(e))
        sys.exit(1)

    # Next, we need to run topgen in order to create all auto-generated files.
    path_in = path_root + '/hw/' + topname + '/data/'
    path_out = path_root + '/hw/' + topname
    cmd = [path_root + '/util/topgen.py',  # "--verbose",
           "-t", path_in + topname + '.hjson',
           "-c", path_in,
           "-o", path_out]

    try:
        print("Running topgen...")
        subprocess.run(cmd,
                       check=True,
                       stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT,
                       universal_newlines=True)

    except subprocess.CalledProcessError as e:
        print("topgen failed: " + str(e))
        sys.exit(1)

    # We need to patch some files:
    # 1. meson.build needs to be pointed to the proper auto-gen files.
    # 2. SW sources currently contain hardcoded references to top_earlgrey. We
    #    need to change some file and variable names in auto-generated files.
    # 3. The build system still uses some sources from the original top level.
    #    We thus need to replace those with the new sources patched in 2.

    # 1.
    cmd = ['sed', '-i', "s/TOPNAME='top_{}'/TOPNAME='top_{}'/g".format(name_old, name),
           path_root + '/meson.build']
    try:
        print("Adjusting meson.build...")
        subprocess.run(cmd,
                       check=True,
                       stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT,
                       universal_newlines=True)

    except subprocess.CalledProcessError as e:
        print("Adjustment of meson.build failed: " + str(e))
        sys.exit(1)

    # 2. and 3.
    print("Adjusting SW files generated by topgen...")
    files = ['top_' + name + '.c',
             'top_' + name + '.h',
             'top_' + name + '_memory.h',
             'top_' + name + '_memory.ld']
    path_in = path_root + '/hw/top_' + name + '/sw/autogen/'
    path_out = path_root + '/hw/top_' + name_old + '/sw/autogen/'

    for file_name in files:

        # Read file produced by topgen.
        with open(path_in + file_name, "r") as file_in:
            text = file_in.read()

        text = re.sub(name, name_old, text)
        text = re.sub(name.capitalize(), name_old.capitalize(), text)
        text = re.sub(name.upper(), name_old.upper(), text)

        # Write file that SW build can deal with.
        file_name_new = re.sub(name, name_old, file_name)
        with open(path_in + file_name_new, "w") as file_out:
            file_out.write(text)

        # Overwrite the files in the tree of the original top level. They are still used by the
        # SW build.
        with open(path_out + file_name_new, "w") as file_out:
            file_out.write(text)

    # Generate the boot_rom to enable the FPGA build.
    print("Generating boot ROM...")
    cmd = ['ninja', '-C', path_root + '/build-out',
           'sw/device/boot_rom/boot_rom_export_fpga_nexysvideo']
    try:
        subprocess.run(cmd,
                       check=True,
                       stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT,
                       universal_newlines=True)

    except subprocess.CalledProcessError as e:
        print("Failed to generate boot ROM: " + str(e))
        sys.exit(1)

    return 0


if __name__ == "__main__":
    main()