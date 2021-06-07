// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package hmac_reg_pkg;

  // Param list
  parameter int NumWords = 8;

  // Address width within the block
  parameter int BlockAw = 12;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////
  typedef struct packed {
    struct packed {
      logic        q;
    } hmac_done;
    struct packed {
      logic        q;
    } fifo_empty;
    struct packed {
      logic        q;
    } hmac_err;
  } hmac_reg2hw_intr_state_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } hmac_done;
    struct packed {
      logic        q;
    } fifo_empty;
    struct packed {
      logic        q;
    } hmac_err;
  } hmac_reg2hw_intr_enable_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } hmac_done;
    struct packed {
      logic        q;
      logic        qe;
    } fifo_empty;
    struct packed {
      logic        q;
      logic        qe;
    } hmac_err;
  } hmac_reg2hw_intr_test_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } hmac_en;
    struct packed {
      logic        q;
      logic        qe;
    } sha_en;
    struct packed {
      logic        q;
      logic        qe;
    } endian_swap;
    struct packed {
      logic        q;
      logic        qe;
    } digest_swap;
  } hmac_reg2hw_cfg_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } hash_start;
    struct packed {
      logic        q;
      logic        qe;
    } hash_process;
  } hmac_reg2hw_cmd_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } hmac_reg2hw_wipe_secret_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } hmac_reg2hw_key_mreg_t;


  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } hmac_done;
    struct packed {
      logic        d;
      logic        de;
    } fifo_empty;
    struct packed {
      logic        d;
      logic        de;
    } hmac_err;
  } hmac_hw2reg_intr_state_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
    } hmac_en;
    struct packed {
      logic        d;
    } sha_en;
    struct packed {
      logic        d;
    } endian_swap;
    struct packed {
      logic        d;
    } digest_swap;
  } hmac_hw2reg_cfg_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
    } fifo_empty;
    struct packed {
      logic        d;
    } fifo_full;
    struct packed {
      logic [4:0]  d;
    } fifo_depth;
  } hmac_hw2reg_status_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } hmac_hw2reg_err_code_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } hmac_hw2reg_key_mreg_t;

  typedef struct packed {
    logic [31:0] d;
  } hmac_hw2reg_digest_mreg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } hmac_hw2reg_msg_length_lower_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } hmac_hw2reg_msg_length_upper_reg_t;


  ///////////////////////////////////////
  // Register to internal design logic //
  ///////////////////////////////////////
  typedef struct packed {
    hmac_reg2hw_intr_state_reg_t intr_state; // [320:318]
    hmac_reg2hw_intr_enable_reg_t intr_enable; // [317:315]
    hmac_reg2hw_intr_test_reg_t intr_test; // [314:309]
    hmac_reg2hw_cfg_reg_t cfg; // [308:301]
    hmac_reg2hw_cmd_reg_t cmd; // [300:297]
    hmac_reg2hw_wipe_secret_reg_t wipe_secret; // [296:264]
    hmac_reg2hw_key_mreg_t [7:0] key; // [263:0]
  } hmac_reg2hw_t;

  ///////////////////////////////////////
  // Internal design logic to register //
  ///////////////////////////////////////
  typedef struct packed {
    hmac_hw2reg_intr_state_reg_t intr_state; // [627:622]
    hmac_hw2reg_cfg_reg_t cfg; // [621:618]
    hmac_hw2reg_status_reg_t status; // [617:611]
    hmac_hw2reg_err_code_reg_t err_code; // [610:578]
    hmac_hw2reg_key_mreg_t [7:0] key; // [577:322]
    hmac_hw2reg_digest_mreg_t [7:0] digest; // [321:66]
    hmac_hw2reg_msg_length_lower_reg_t msg_length_lower; // [65:33]
    hmac_hw2reg_msg_length_upper_reg_t msg_length_upper; // [32:0]
  } hmac_hw2reg_t;

  // Register Address
  parameter logic [BlockAw-1:0] HMAC_INTR_STATE_OFFSET = 12'h 0;
  parameter logic [BlockAw-1:0] HMAC_INTR_ENABLE_OFFSET = 12'h 4;
  parameter logic [BlockAw-1:0] HMAC_INTR_TEST_OFFSET = 12'h 8;
  parameter logic [BlockAw-1:0] HMAC_CFG_OFFSET = 12'h c;
  parameter logic [BlockAw-1:0] HMAC_CMD_OFFSET = 12'h 10;
  parameter logic [BlockAw-1:0] HMAC_STATUS_OFFSET = 12'h 14;
  parameter logic [BlockAw-1:0] HMAC_ERR_CODE_OFFSET = 12'h 18;
  parameter logic [BlockAw-1:0] HMAC_WIPE_SECRET_OFFSET = 12'h 1c;
  parameter logic [BlockAw-1:0] HMAC_KEY_0_OFFSET = 12'h 20;
  parameter logic [BlockAw-1:0] HMAC_KEY_1_OFFSET = 12'h 24;
  parameter logic [BlockAw-1:0] HMAC_KEY_2_OFFSET = 12'h 28;
  parameter logic [BlockAw-1:0] HMAC_KEY_3_OFFSET = 12'h 2c;
  parameter logic [BlockAw-1:0] HMAC_KEY_4_OFFSET = 12'h 30;
  parameter logic [BlockAw-1:0] HMAC_KEY_5_OFFSET = 12'h 34;
  parameter logic [BlockAw-1:0] HMAC_KEY_6_OFFSET = 12'h 38;
  parameter logic [BlockAw-1:0] HMAC_KEY_7_OFFSET = 12'h 3c;
  parameter logic [BlockAw-1:0] HMAC_DIGEST_0_OFFSET = 12'h 40;
  parameter logic [BlockAw-1:0] HMAC_DIGEST_1_OFFSET = 12'h 44;
  parameter logic [BlockAw-1:0] HMAC_DIGEST_2_OFFSET = 12'h 48;
  parameter logic [BlockAw-1:0] HMAC_DIGEST_3_OFFSET = 12'h 4c;
  parameter logic [BlockAw-1:0] HMAC_DIGEST_4_OFFSET = 12'h 50;
  parameter logic [BlockAw-1:0] HMAC_DIGEST_5_OFFSET = 12'h 54;
  parameter logic [BlockAw-1:0] HMAC_DIGEST_6_OFFSET = 12'h 58;
  parameter logic [BlockAw-1:0] HMAC_DIGEST_7_OFFSET = 12'h 5c;
  parameter logic [BlockAw-1:0] HMAC_MSG_LENGTH_LOWER_OFFSET = 12'h 60;
  parameter logic [BlockAw-1:0] HMAC_MSG_LENGTH_UPPER_OFFSET = 12'h 64;

  // Reset values for hwext registers and their fields
  parameter logic [2:0] HMAC_INTR_TEST_RESVAL = 3'h 0;
  parameter logic [0:0] HMAC_INTR_TEST_HMAC_DONE_RESVAL = 1'h 0;
  parameter logic [0:0] HMAC_INTR_TEST_FIFO_EMPTY_RESVAL = 1'h 0;
  parameter logic [0:0] HMAC_INTR_TEST_HMAC_ERR_RESVAL = 1'h 0;
  parameter logic [3:0] HMAC_CFG_RESVAL = 4'h 4;
  parameter logic [0:0] HMAC_CFG_ENDIAN_SWAP_RESVAL = 1'h 1;
  parameter logic [0:0] HMAC_CFG_DIGEST_SWAP_RESVAL = 1'h 0;
  parameter logic [1:0] HMAC_CMD_RESVAL = 2'h 0;
  parameter logic [8:0] HMAC_STATUS_RESVAL = 9'h 1;
  parameter logic [0:0] HMAC_STATUS_FIFO_EMPTY_RESVAL = 1'h 1;
  parameter logic [31:0] HMAC_WIPE_SECRET_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_KEY_0_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_KEY_1_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_KEY_2_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_KEY_3_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_KEY_4_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_KEY_5_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_KEY_6_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_KEY_7_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_DIGEST_0_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_DIGEST_1_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_DIGEST_2_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_DIGEST_3_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_DIGEST_4_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_DIGEST_5_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_DIGEST_6_RESVAL = 32'h 0;
  parameter logic [31:0] HMAC_DIGEST_7_RESVAL = 32'h 0;

  // Window parameter
  parameter logic [BlockAw-1:0] HMAC_MSG_FIFO_OFFSET = 12'h 800;
  parameter logic [BlockAw-1:0] HMAC_MSG_FIFO_SIZE   = 12'h 800;

  // Register Index
  typedef enum int {
    HMAC_INTR_STATE,
    HMAC_INTR_ENABLE,
    HMAC_INTR_TEST,
    HMAC_CFG,
    HMAC_CMD,
    HMAC_STATUS,
    HMAC_ERR_CODE,
    HMAC_WIPE_SECRET,
    HMAC_KEY_0,
    HMAC_KEY_1,
    HMAC_KEY_2,
    HMAC_KEY_3,
    HMAC_KEY_4,
    HMAC_KEY_5,
    HMAC_KEY_6,
    HMAC_KEY_7,
    HMAC_DIGEST_0,
    HMAC_DIGEST_1,
    HMAC_DIGEST_2,
    HMAC_DIGEST_3,
    HMAC_DIGEST_4,
    HMAC_DIGEST_5,
    HMAC_DIGEST_6,
    HMAC_DIGEST_7,
    HMAC_MSG_LENGTH_LOWER,
    HMAC_MSG_LENGTH_UPPER
  } hmac_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] HMAC_PERMIT [26] = '{
    4'b 0001, // index[ 0] HMAC_INTR_STATE
    4'b 0001, // index[ 1] HMAC_INTR_ENABLE
    4'b 0001, // index[ 2] HMAC_INTR_TEST
    4'b 0001, // index[ 3] HMAC_CFG
    4'b 0001, // index[ 4] HMAC_CMD
    4'b 0011, // index[ 5] HMAC_STATUS
    4'b 1111, // index[ 6] HMAC_ERR_CODE
    4'b 1111, // index[ 7] HMAC_WIPE_SECRET
    4'b 1111, // index[ 8] HMAC_KEY_0
    4'b 1111, // index[ 9] HMAC_KEY_1
    4'b 1111, // index[10] HMAC_KEY_2
    4'b 1111, // index[11] HMAC_KEY_3
    4'b 1111, // index[12] HMAC_KEY_4
    4'b 1111, // index[13] HMAC_KEY_5
    4'b 1111, // index[14] HMAC_KEY_6
    4'b 1111, // index[15] HMAC_KEY_7
    4'b 1111, // index[16] HMAC_DIGEST_0
    4'b 1111, // index[17] HMAC_DIGEST_1
    4'b 1111, // index[18] HMAC_DIGEST_2
    4'b 1111, // index[19] HMAC_DIGEST_3
    4'b 1111, // index[20] HMAC_DIGEST_4
    4'b 1111, // index[21] HMAC_DIGEST_5
    4'b 1111, // index[22] HMAC_DIGEST_6
    4'b 1111, // index[23] HMAC_DIGEST_7
    4'b 1111, // index[24] HMAC_MSG_LENGTH_LOWER
    4'b 1111  // index[25] HMAC_MSG_LENGTH_UPPER
  };
endpackage
