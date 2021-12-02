#  NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
#  This is an automatically generated file by mchristi on Mon 19 Aug 2019 04:24:53 PM CEST
# 
#  cmd:    swerv  
# 
# To use this in a perf script, use 'require $RV_ROOT/configs/config.pl'
# Reference the hash via $config{name}..


%config = (
            'pic' => {
                       'pic_meigwctrl_offset' => '0x4000',
                       'pic_int_words' => 1,
                       'pic_total_int_plus1' => 9,
                       'pic_size' => 32,
                       'pic_meie_offset' => '0x2000',
                       'pic_mpiccfg_offset' => '0x3000',
                       'pic_meipt_offset' => '0x3004',
                       'pic_total_int' => 8,
                       'pic_region' => '0xf',
                       'pic_meigwclr_offset' => '0x5000',
                       'pic_base_addr' => '0xf00c0000',
                       'pic_meip_offset' => '0x1000',
                       'pic_meipl_offset' => '0x0000',
                       'pic_offset' => '0xc0000',
                       'pic_bits' => 15
                     },
            'dccm' => {
                        'dccm_reserved' => '0x1000',
                        'dccm_ecc_width' => 7,
                        'lsu_sb_bits' => 16,
                        'dccm_size_64' => '',
                        'dccm_enable' => '1',
                        'dccm_offset' => '0x40000',
                        'dccm_data_cell' => 'ram_2048x39',
                        'dccm_byte_width' => '4',
                        'dccm_rows' => '2048',
                        'dccm_region' => '0xf',
                        'dccm_bits' => 16,
                        'dccm_bank_bits' => 3,
                        'dccm_eadr' => '0xf004ffff',
                        'dccm_index_bits' => 11,
                        'dccm_width_bits' => 2,
                        'dccm_fdata_width' => 39,
                        'dccm_sadr' => '0xf0040000',
                        'dccm_num_banks' => '8',
                        'dccm_num_banks_8' => '',
                        'dccm_data_width' => 32,
                        'dccm_size' => 64
                      },
            'num_mmode_perf_regs' => '4',
            'max_mmode_perf_event' => '50',
            'target' => 'default',
            'core' => {
                        'dma_buf_depth' => '4',
                        'lsu_stbuf_depth' => '8',
                        'dec_instbuf_depth' => '4',
                        'lsu_num_nbload_width' => '3',
                        'lsu_num_nbload' => '8'
                      },
            'regwidth' => '32',
            'bus' => {
                       'ifu_bus_tag' => '3',
                       'lsu_bus_tag' => 4,
                       'dma_bus_tag' => '1',
                       'sb_bus_tag' => '1'
                     },
            'icache' => {
                          'icache_tag_cell' => 'ram_64x21',
                          'icache_tag_low' => '6',
                          'icache_ic_rows' => '256',
                          'icache_tag_depth' => 64,
                          'icache_enable' => '1',
                          'icache_size' => 16,
                          'icache_ic_index' => 8,
                          'icache_taddr_high' => 5,
                          'icache_data_cell' => 'ram_256x34',
                          'icache_ic_depth' => 8,
                          'icache_tag_high' => 12
                        },
            'retstack' => {
                            'ret_stack_size' => '4'
                          },
            'testbench' => {
                             'build_axi4' => '',
                             'RV_TOP' => '`TOP.rvtop',
                             'datawidth' => '64',
                             'assert_on' => '',
                             'SDVT_AHB' => '1',
                             'sterr_rollback' => '0',
                             'ext_datawidth' => '64',
                             'ext_addrwidth' => '32',
                             'CPU_TOP' => '`RV_TOP.swerv',
                             'TOP' => 'tb_top',
                             'lderr_rollback' => '1',
                             'clock_period' => '100'
                           },
            'iccm' => {
                        'iccm_bits' => 19,
                        'iccm_region' => '0xe',
                        'iccm_rows' => '16384',
                        'iccm_index_bits' => 14,
                        'iccm_eadr' => '0xee07ffff',
                        'iccm_bank_bits' => 3,
                        'iccm_num_banks_8' => '',
                        'iccm_num_banks' => '8',
                        'iccm_sadr' => '0xee000000',
                        'iccm_size' => 512,
                        'iccm_reserved' => '0x1000',
                        'iccm_size_512' => '',
                        'iccm_data_cell' => 'ram_16384x39',
                        'iccm_offset' => '0xe000000'
                      },
            'numiregs' => '32',
            'triggers' => [
                            {
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'poke_mask' => [
                                               '0x081818c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ]
                            },
                            {
                              'poke_mask' => [
                                               '0x081818c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ]
                            },
                            {
                              'poke_mask' => [
                                               '0x081818c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ]
                            },
                            {
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'poke_mask' => [
                                               '0x081818c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ]
                            }
                          ],
            'nmi_vec' => '0x11110000',
            'xlen' => 32,
            'even_odd_trigger_chains' => 'true',
            'csr' => {
                       'dicad0' => {
                                     'mask' => '0xffffffff',
                                     'number' => '0x7c9',
                                     'debug' => 'true',
                                     'comment' => 'Cache diagnostics.',
                                     'reset' => '0x0',
                                     'exists' => 'true'
                                   },
                       'pmpaddr0' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr4' => {
                                       'exists' => 'false'
                                     },
                       'meicurpl' => {
                                       'exists' => 'true',
                                       'comment' => 'External interrupt current priority level.',
                                       'reset' => '0x0',
                                       'number' => '0xbcc',
                                       'mask' => '0xf'
                                     },
                       'mhpmcounter5' => {
                                           'reset' => '0x0',
                                           'exists' => 'true',
                                           'mask' => '0xffffffff'
                                         },
                       'tselect' => {
                                      'exists' => 'true',
                                      'reset' => '0x0',
                                      'mask' => '0x3'
                                    },
                       'misa' => {
                                   'reset' => '0x40001104',
                                   'exists' => 'true',
                                   'mask' => '0x0'
                                 },
                       'pmpaddr5' => {
                                       'exists' => 'false'
                                     },
                       'instret' => {
                                      'exists' => 'false'
                                    },
                       'meicpct' => {
                                      'reset' => '0x0',
                                      'comment' => 'External claim id/priority capture.',
                                      'exists' => 'true',
                                      'mask' => '0x0',
                                      'number' => '0xbca'
                                    },
                       'mhpmcounter3' => {
                                           'exists' => 'true',
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff'
                                         },
                       'meicidpl' => {
                                       'reset' => '0x0',
                                       'comment' => 'External interrupt claim id priority level.',
                                       'exists' => 'true',
                                       'number' => '0xbcb',
                                       'mask' => '0xf'
                                     },
                       'mimpid' => {
                                     'mask' => '0x0',
                                     'reset' => '0x1',
                                     'exists' => 'true'
                                   },
                       'pmpaddr3' => {
                                       'exists' => 'false'
                                     },
                       'mhpmcounter4' => {
                                           'exists' => 'true',
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff'
                                         },
                       'miccmect' => {
                                       'exists' => 'true',
                                       'reset' => '0x0',
                                       'mask' => '0xffffffff',
                                       'number' => '0x7f1'
                                     },
                       'mpmc' => {
                                   'comment' => 'Core pause: Implemented as read only.',
                                   'reset' => '0x0',
                                   'exists' => 'true',
                                   'mask' => '0x0',
                                   'number' => '0x7c6'
                                 },
                       'mhpmcounter6h' => {
                                            'mask' => '0xffffffff',
                                            'exists' => 'true',
                                            'reset' => '0x0'
                                          },
                       'pmpaddr1' => {
                                       'exists' => 'false'
                                     },
                       'mhpmcounter4h' => {
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0',
                                            'exists' => 'true'
                                          },
                       'pmpaddr2' => {
                                       'exists' => 'false'
                                     },
                       'dcsr' => {
                                   'exists' => 'true',
                                   'poke_mask' => '0x00008dcc',
                                   'reset' => '0x40000003',
                                   'mask' => '0x00008c04'
                                 },
                       'mhpmcounter6' => {
                                           'mask' => '0xffffffff',
                                           'exists' => 'true',
                                           'reset' => '0x0'
                                         },
                       'mhpmcounter3h' => {
                                            'exists' => 'true',
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff'
                                          },
                       'pmpaddr10' => {
                                        'exists' => 'false'
                                      },
                       'mhpmevent4' => {
                                         'exists' => 'true',
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff'
                                       },
                       'mstatus' => {
                                      'exists' => 'true',
                                      'reset' => '0x1800',
                                      'mask' => '0x88'
                                    },
                       'pmpcfg2' => {
                                      'exists' => 'false'
                                    },
                       'pmpaddr12' => {
                                        'exists' => 'false'
                                      },
                       'dicago' => {
                                     'number' => '0x7cb',
                                     'mask' => '0x0',
                                     'debug' => 'true',
                                     'comment' => 'Cache diagnostics.',
                                     'reset' => '0x0',
                                     'exists' => 'true'
                                   },
                       'mhpmcounter5h' => {
                                            'mask' => '0xffffffff',
                                            'exists' => 'true',
                                            'reset' => '0x0'
                                          },
                       'time' => {
                                   'exists' => 'false'
                                 },
                       'mip' => {
                                  'mask' => '0x0',
                                  'poke_mask' => '0x40000888',
                                  'exists' => 'true',
                                  'reset' => '0x0'
                                },
                       'mfdc' => {
                                   'mask' => '0x000707ff',
                                   'number' => '0x7f9',
                                   'exists' => 'true',
                                   'reset' => '0x00070000'
                                 },
                       'meipt' => {
                                    'exists' => 'true',
                                    'comment' => 'External interrupt priority threshold.',
                                    'reset' => '0x0',
                                    'number' => '0xbc9',
                                    'mask' => '0xf'
                                  },
                       'pmpaddr7' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr14' => {
                                        'exists' => 'false'
                                      },
                       'pmpaddr8' => {
                                       'exists' => 'false'
                                     },
                       'marchid' => {
                                      'mask' => '0x0',
                                      'reset' => '0x0000000b',
                                      'exists' => 'true'
                                    },
                       'mcgc' => {
                                   'mask' => '0x000001ff',
                                   'number' => '0x7f8',
                                   'poke_mask' => '0x000001ff',
                                   'exists' => 'true',
                                   'reset' => '0x0'
                                 },
                       'pmpcfg3' => {
                                      'exists' => 'false'
                                    },
                       'pmpaddr6' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr11' => {
                                        'exists' => 'false'
                                      },
                       'mdccmect' => {
                                       'exists' => 'true',
                                       'reset' => '0x0',
                                       'number' => '0x7f2',
                                       'mask' => '0xffffffff'
                                     },
                       'pmpcfg1' => {
                                      'exists' => 'false'
                                    },
                       'mhpmevent3' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'pmpaddr15' => {
                                        'exists' => 'false'
                                      },
                       'mie' => {
                                  'mask' => '0x40000888',
                                  'reset' => '0x0',
                                  'exists' => 'true'
                                },
                       'mhpmevent6' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'pmpaddr13' => {
                                        'exists' => 'false'
                                      },
                       'mcpc' => {
                                   'number' => '0x7c2',
                                   'mask' => '0x0',
                                   'reset' => '0x0',
                                   'exists' => 'true'
                                 },
                       'mhpmevent5' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'dicad1' => {
                                     'debug' => 'true',
                                     'number' => '0x7ca',
                                     'mask' => '0x3',
                                     'exists' => 'true',
                                     'reset' => '0x0',
                                     'comment' => 'Cache diagnostics.'
                                   },
                       'pmpaddr9' => {
                                       'exists' => 'false'
                                     },
                       'pmpcfg0' => {
                                      'exists' => 'false'
                                    },
                       'dmst' => {
                                   'debug' => 'true',
                                   'mask' => '0x0',
                                   'number' => '0x7c4',
                                   'exists' => 'true',
                                   'comment' => 'Memory synch trigger: Flush caches in debug mode.',
                                   'reset' => '0x0'
                                 },
                       'dicawics' => {
                                       'number' => '0x7c8',
                                       'mask' => '0x0130fffc',
                                       'debug' => 'true',
                                       'reset' => '0x0',
                                       'comment' => 'Cache diagnostics.',
                                       'exists' => 'true'
                                     },
                       'cycle' => {
                                    'exists' => 'false'
                                  },
                       'mvendorid' => {
                                        'mask' => '0x0',
                                        'exists' => 'true',
                                        'reset' => '0x45'
                                      },
                       'micect' => {
                                     'reset' => '0x0',
                                     'exists' => 'true',
                                     'mask' => '0xffffffff',
                                     'number' => '0x7f0'
                                   }
                     },
            'memmap' => {
                          'external_data_1' => '0x00000000',
                          'serialio' => '0xd0580000',
                          'debug_sb_mem' => '0xb0580000',
                          'external_prog' => '0xb0000000',
                          'external_data' => '0xc0580000'
                        },
            'verilator' => '',
            'protection' => {
                              'inst_access_addr1' => '0x00000000',
                              'data_access_addr0' => '0x00000000',
                              'data_access_addr4' => '0x00000000',
                              'inst_access_mask5' => '0xffffffff',
                              'inst_access_addr4' => '0x00000000',
                              'inst_access_addr0' => '0x00000000',
                              'data_access_addr1' => '0x00000000',
                              'data_access_mask5' => '0xffffffff',
                              'inst_access_addr2' => '0x00000000',
                              'inst_access_addr7' => '0x00000000',
                              'inst_access_enable0' => '0x0',
                              'data_access_mask3' => '0xffffffff',
                              'inst_access_enable7' => '0x0',
                              'inst_access_enable5' => '0x0',
                              'inst_access_mask6' => '0xffffffff',
                              'inst_access_enable4' => '0x0',
                              'data_access_addr7' => '0x00000000',
                              'data_access_addr2' => '0x00000000',
                              'inst_access_mask3' => '0xffffffff',
                              'data_access_enable0' => '0x0',
                              'data_access_enable4' => '0x0',
                              'data_access_enable7' => '0x0',
                              'data_access_mask6' => '0xffffffff',
                              'data_access_enable5' => '0x0',
                              'data_access_addr6' => '0x00000000',
                              'inst_access_enable1' => '0x0',
                              'data_access_mask7' => '0xffffffff',
                              'data_access_mask2' => '0xffffffff',
                              'inst_access_addr3' => '0x00000000',
                              'data_access_enable6' => '0x0',
                              'inst_access_addr6' => '0x00000000',
                              'data_access_enable1' => '0x0',
                              'inst_access_mask2' => '0xffffffff',
                              'inst_access_mask7' => '0xffffffff',
                              'inst_access_enable6' => '0x0',
                              'data_access_addr3' => '0x00000000',
                              'data_access_enable2' => '0x0',
                              'data_access_addr5' => '0x00000000',
                              'data_access_enable3' => '0x0',
                              'inst_access_mask4' => '0xffffffff',
                              'data_access_mask1' => '0xffffffff',
                              'inst_access_mask0' => '0xffffffff',
                              'inst_access_addr5' => '0x00000000',
                              'inst_access_enable3' => '0x0',
                              'inst_access_enable2' => '0x0',
                              'inst_access_mask1' => '0xffffffff',
                              'data_access_mask0' => '0xffffffff',
                              'data_access_mask4' => '0xffffffff'
                            },
            'harts' => 1,
            'bht' => {
                       'bht_hash_string' => '{ghr[3:2] ^ {ghr[3+1], {4-1-2{1\'b0} } },hashin[5:4]^ghr[2-1:0]}',
                       'bht_ghr_pad' => 'fghr[4],3\'b0',
                       'bht_array_depth' => 16,
                       'bht_ghr_pad2' => 'fghr[4:3],2\'b0',
                       'bht_ghr_range' => '4:0',
                       'bht_addr_hi' => 7,
                       'bht_size' => 128,
                       'bht_ghr_size' => 5,
                       'bht_addr_lo' => '4'
                     },
            'reset_vec' => '0x80000000',
            'btb' => {
                       'btb_index1_hi' => 5,
                       'btb_index2_hi' => 7,
                       'btb_index3_lo' => 8,
                       'btb_addr_lo' => '4',
                       'btb_addr_hi' => 5,
                       'btb_btag_size' => 9,
                       'btb_array_depth' => 4,
                       'btb_index3_hi' => 9,
                       'btb_btag_fold' => 1,
                       'btb_index1_lo' => '4',
                       'btb_size' => 32,
                       'btb_index2_lo' => 6
                     },
            'physical' => '1',
            'tec_rv_icg' => 'clockhdr'
          );
1;
