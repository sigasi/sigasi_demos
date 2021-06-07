# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
"""
Generate HTML documentation from validated configuration Hjson tree
"""

from .html_helpers import render_td


def genout(outfile, msg):
    outfile.write(msg)


def name_width(x):
    if 'width' not in x or x['width'] == '1':
        return x['name']
    return x['name'] + '[' + str(int(x['width'], 0) - 1) + ':0]'


# Must have called cfg_validate, so should have no errors


def gen_cfg_html(cfgs, outfile):
    rnames = cfgs['genrnames']

    genout(outfile, "<p>Referring to the \n")
    genout(
        outfile,
        "<a href=\"https://docs.opentitan.org/doc/rm/comportability_specification\">\n"
    )
    genout(outfile,
           "Comportable guideline for peripheral device functionality</a>,\n")
    genout(outfile,
           "the module <b><code>" + cfgs['name'] + "</code></b> has \n")
    genout(outfile, "the following hardware interfaces defined.</p>\n")
    # clocks
    genout(
        outfile, "<p><i>Primary Clock:</i> <b><code>" + cfgs['clock_primary'] +
        "</code></b></p>\n")
    if 'other_clock_list' in cfgs:
        genout(outfile, "<p><i>Other Clocks:</i></p>\n")
    else:
        genout(outfile, "<p><i>Other Clocks: none</i></p>\n")
    # bus interfaces
    genout(
        outfile, "<p><i>Bus Device Interface:</i> <b><code>" +
        cfgs['bus_device'] + "</code></b></p>\n")
    if 'bus_host' in cfgs:
        genout(
            outfile, "<p><i>Bus Host Interface:</i> <b><code>" +
            cfgs['bus_host'] + "</code></b></p>\n")
    else:
        genout(outfile, "<p><i>Bus Host Interface: none</i></p>\n")

    # IO
    ios = ([('input', x) for x in cfgs.get('available_input_list', [])] +
           [('output', x) for x in cfgs.get('available_output_list', [])] +
           [('inout', x) for x in cfgs.get('available_inout_list', [])])
    if ios:
        genout(outfile, "<p><i>Peripheral Pins for Chip IO:</i></p>\n")
        genout(
            outfile, "<table class=\"cfgtable\"><tr>" +
            "<th>Pin name</th><th>direction</th>" +
            "<th>Description</th></tr>\n")
        for direction, x in ios:
            genout(outfile,
                   '<tr><td>{}</td><td>{}</td>{}</tr>'
                   .format(name_width(x),
                           direction,
                           render_td(x['desc'], rnames, None)))
        genout(outfile, "</table>\n")
    else:
        genout(outfile, "<p><i>Peripheral Pins for Chip IO: none</i></p>\n")

    interrupts = cfgs.get('interrupt_list', [])
    if not interrupts:
        genout(outfile, "<p><i>Interrupts: none</i></p>\n")
    else:
        genout(outfile, "<p><i>Interrupts:</i></p>\n")
        genout(
            outfile, "<table class=\"cfgtable\"><tr><th>Interrupt Name</th>" +
            "<th>Description</th></tr>\n")
        for x in interrupts:
            genout(outfile,
                   '<tr><td>{}</td>{}</tr>'
                   .format(name_width(x),
                           render_td(x['desc'], rnames, None)))
        genout(outfile, "</table>\n")

    alerts = cfgs.get('alert_list', [])
    if not alerts:
        genout(outfile, "<p><i>Security Alerts: none</i></p>\n")
    else:
        genout(outfile, "<p><i>Security Alerts:</i></p>\n")
        genout(
            outfile, "<table class=\"cfgtable\"><tr><th>Alert Name</th>" +
            "<th>Description</th></tr>\n")
        for x in alerts:
            genout(outfile,
                   '<tr><td>{}</td>{}</tr>'
                   .format(x['name'],
                           render_td(x['desc'], rnames, None)))
        genout(outfile, "</table>\n")
