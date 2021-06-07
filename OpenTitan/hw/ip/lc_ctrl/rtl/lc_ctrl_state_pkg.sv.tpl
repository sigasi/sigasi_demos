// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Life cycle state encoding definition.
//
// DO NOT EDIT THIS FILE DIRECTLY.
// It has been generated with
// $ ./util/design/gen-lc-state-enc.py --seed ${lc_st_enc.config['seed']}
//
package lc_ctrl_state_pkg;
<%
  data_width = lc_st_enc.config['secded']['data_width']
  ecc_width  = lc_st_enc.config['secded']['ecc_width']

  def _to_pascal_case(inp):
    # Split by underscore. For each word, use str.capitalize if the word is all
    # one case. For words in mixed case, ensure the first character is
    # capitalized and leave them be otherwise.
    words = []
    for p in inp.split('_'):
        if not p:
            # Ignore leading and trailing underscores
            continue

        if p == p.lower() or p == p.upper():
            words.append(p.capitalize())
        else:
            words.append(p[0].upper() + p[1:])

    return ''.join(words)

  def _print_state_enum(prefix, name, config):
    indent = ' ' * 4

    # Determine name length for nice alignment; build a new dictionary keyed by
    # the Pascal-case version of the state names.
    state_len = 0
    entry_len = 3
    pstates = {}
    for state, state_cfg in config[name].items():
      pstate = _to_pascal_case(state)
      state_len = max(state_len, len(pstate))
      for entry in state_cfg:
        entry_len = max(entry_len, len(entry))

      # Since _to_pascal_case isn't injective, we should check we didn't get
      # any collisions.
      assert pstate not in pstates
      pstates[pstate] = state_cfg

    out = []
    for i, (pstate, state_cfg) in enumerate(pstates.items()):
      if i:
        out.append(',\n')
      out += [indent, prefix, pstate,
              ' ' * (state_len - len(pstate)), ' = {']
      # Need to iterate in reverse since this is a packed value
      for j, entry in enumerate(reversed(state_cfg)):
          if j:
            out.append(', ')

          ename = 'ZRO' if entry == '0' else entry
          out += [' ' * (entry_len - len(ename)), ename]
      out.append('}')

    return ''.join(out)
%>
  import prim_util_pkg::vbits;

  ///////////////////////////////
  // General size declarations //
  ///////////////////////////////

  parameter int LcValueWidth = ${data_width};

  parameter int NumLcStateValues = ${lc_st_enc.config['num_lc_state_words']};
  parameter int LcStateWidth = NumLcStateValues * LcValueWidth;
  parameter int NumLcStates = ${len(lc_st_enc.config['lc_state'])};
  parameter int DecLcStateWidth = vbits(NumLcStates);

  parameter int NumLcCountValues = ${lc_st_enc.config['num_lc_cnt_words']};
  parameter int LcCountWidth = NumLcCountValues * LcValueWidth;
  parameter int NumLcCountStates = ${len(lc_st_enc.config['lc_cnt'])};
  parameter int DecLcCountWidth = vbits(NumLcCountStates);

  parameter int NumLcIdStateValues = ${lc_st_enc.config['num_lc_id_state_words']};
  parameter int LcIdStateWidth = NumLcIdStateValues * LcValueWidth;
  parameter int NumLcIdStates = ${len(lc_st_enc.config['lc_id_state'])};
  parameter int DecLcIdStateWidth = vbits(NumLcIdStates+1);

  /////////////////////////////////////////////
  // Life cycle manufacturing state encoding //
  /////////////////////////////////////////////

  // These values have been generated such that they are incrementally writeable with respect
  // to the ECC polynomial specified. The values are used to define the life cycle manufacturing
  // state and transition counter encoding in lc_ctrl_pkg.sv.
  //
  // The values are unique and have the following statistics (considering all ${data_width}
  // data and ${ecc_width} ECC bits):
  //
  // - Minimum Hamming weight: ${lc_st_enc.config['stats']['min_hw']}
  // - Maximum Hamming weight: ${lc_st_enc.config['stats']['max_hw']}
  // - Minimum Hamming distance from any other value: ${lc_st_enc.config['stats']['min_hd']}
  // - Maximum Hamming distance from any other value: ${lc_st_enc.config['stats']['max_hd']}
  //
  // Hamming distance histogram:
  //
% for bar in lc_st_enc.config['stats']['bars']:
  // ${bar}
% endfor
  //
  //
  // Note that the ECC bits are not defined in this package as they will be calculated by
  // the OTP ECC logic at runtime.

  // The A/B values are used for the encoded LC state.
% for word in lc_st_enc.config['genwords']['lc_state']:
  parameter logic [${data_width-1}:0] A${loop.index} = ${data_width}'b${word[0][ecc_width:]}; // ECC: ${ecc_width}'b${word[0][0:ecc_width]}
  parameter logic [${data_width-1}:0] B${loop.index} = ${data_width}'b${word[1][ecc_width:]}; // ECC: ${ecc_width}'b${word[1][0:ecc_width]}

% endfor

  // The C/D values are used for the encoded LC transition counter.
% for word in lc_st_enc.config['genwords']['lc_cnt']:
  parameter logic [${data_width-1}:0] C${loop.index} = ${data_width}'b${word[0][ecc_width:]}; // ECC: ${ecc_width}'b${word[0][0:ecc_width]}
  parameter logic [${data_width-1}:0] D${loop.index} = ${data_width}'b${word[1][ecc_width:]}; // ECC: ${ecc_width}'b${word[1][0:ecc_width]}

% endfor

  // The E/F values are used for the encoded ID state.
% for word in lc_st_enc.config['genwords']['lc_id_state']:
  parameter logic [${data_width-1}:0] E${loop.index} = ${data_width}'b${word[0][ecc_width:]}; // ECC: ${ecc_width}'b${word[0][0:ecc_width]}
  parameter logic [${data_width-1}:0] F${loop.index} = ${data_width}'b${word[1][ecc_width:]}; // ECC: ${ecc_width}'b${word[1][0:ecc_width]}

% endfor

  parameter logic [${data_width-1}:0] ZRO = ${data_width}'h0;

  ////////////////////////
  // Derived enum types //
  ////////////////////////

  typedef enum logic [LcStateWidth-1:0] {
${_print_state_enum('LcSt', 'lc_state', lc_st_enc.config)}
  } lc_state_e;

  typedef enum logic [LcIdStateWidth-1:0] {
${_print_state_enum('Lc', 'lc_id_state', lc_st_enc.config)}
  } lc_id_state_e;

  typedef enum logic [LcCountWidth-1:0] {
${_print_state_enum('LcCnt', 'lc_cnt', lc_st_enc.config)}
  } lc_cnt_e;

  // Decoded life cycle state, used to interface with CSRs and TAP.
  typedef enum logic [DecLcStateWidth-1:0] {
% for state in lc_st_enc.config['lc_state'].keys():
    DecLcSt${_to_pascal_case(state)},
% endfor
    DecLcStPostTrans,
    DecLcStEscalate,
    DecLcStInvalid
  } dec_lc_state_e;

  typedef enum logic [DecLcIdStateWidth-1:0] {
% for state in lc_st_enc.config['lc_id_state'].keys():
    DecLc${_to_pascal_case(state)},
% endfor
    DecLcIdInvalid
  } dec_lc_id_state_e;

  typedef logic [DecLcCountWidth-1:0] dec_lc_cnt_t;


  ///////////////////////////////////////////
  // Hashed RAW unlock and all-zero tokens //
  ///////////////////////////////////////////

  parameter int LcTokenWidth = ${lc_st_enc.config['token_size']};
  typedef logic [LcTokenWidth-1:0] lc_token_t;
<% token_size = lc_st_enc.config['token_size'] %>
% for token in lc_st_enc.config['tokens']:
  parameter lc_token_t ${token['name']} = {
    ${"{0:}'h{1:0X}".format(token_size, token['value'])}
  };
% endfor

endpackage : lc_ctrl_state_pkg
