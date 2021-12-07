#  NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
#  This is an automatically generated file by titouanvervack on Mon Dec  6 20:49:22 PST 2021
# 
#  cmd:    swerv  
# 
# To use this in a perf script, use 'require $RV_ROOT/configs/config.pl'
# Reference the hash via $config{name}..


%config = (
            'xlen' => 32,
            'csr' => {
                       'mhpmcounter3' => {
                                           'exists' => 'true',
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff'
                                         },
                       'dcsr' => {
                                   'mask' => '0x00008c04',
                                   'exists' => 'true',
                                   'poke_mask' => '0x00008dcc',
                                   'debug' => 'true',
                                   'reset' => '0x40000003'
                                 },
                       'mhartstart' => {
                                         'exists' => 'true',
                                         'comment' => 'Hart start mask',
                                         'shared' => 'true',
                                         'reset' => '0x1',
                                         'number' => '0x7fc',
                                         'mask' => '0x0'
                                       },
                       'mitcnt0' => {
                                      'exists' => 'true',
                                      'reset' => '0x0',
                                      'number' => '0x7d2',
                                      'mask' => '0xffffffff'
                                    },
                       'mhartid' => {
                                      'exists' => 'true',
                                      'poke_mask' => '0xfffffff0',
                                      'reset' => '0x0',
                                      'mask' => '0x0'
                                    },
                       'mscause' => {
                                      'mask' => '0x0000000f',
                                      'number' => '0x7ff',
                                      'reset' => '0x0',
                                      'exists' => 'true'
                                    },
                       'mitctl0' => {
                                      'mask' => '0x00000007',
                                      'number' => '0x7d4',
                                      'reset' => '0x1',
                                      'exists' => 'true'
                                    },
                       'mitctl1' => {
                                      'mask' => '0x0000000f',
                                      'reset' => '0x1',
                                      'number' => '0x7d7',
                                      'exists' => 'true'
                                    },
                       'instret' => {
                                      'exists' => 'false'
                                    },
                       'mitcnt1' => {
                                      'exists' => 'true',
                                      'number' => '0x7d5',
                                      'reset' => '0x0',
                                      'mask' => '0xffffffff'
                                    },
                       'pmpaddr13' => {
                                        'exists' => 'false'
                                      },
                       'mhpmcounter4h' => {
                                            'mask' => '0xffffffff',
                                            'exists' => 'true',
                                            'reset' => '0x0'
                                          },
                       'mcounteren' => {
                                         'exists' => 'false'
                                       },
                       'time' => {
                                   'exists' => 'false'
                                 },
                       'dicawics' => {
                                       'number' => '0x7c8',
                                       'reset' => '0x0',
                                       'debug' => 'true',
                                       'exists' => 'true',
                                       'mask' => '0x0130fffc',
                                       'comment' => 'Cache diagnostics.'
                                     },
                       'mhpmevent3' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'cycle' => {
                                    'exists' => 'false'
                                  },
                       'mhpmcounter5h' => {
                                            'mask' => '0xffffffff',
                                            'exists' => 'true',
                                            'reset' => '0x0'
                                          },
                       'pmpaddr2' => {
                                       'exists' => 'false'
                                     },
                       'mcgc' => {
                                   'mask' => '0x000003ff',
                                   'shared' => 'true',
                                   'number' => '0x7f8',
                                   'reset' => '0x200',
                                   'poke_mask' => '0x000003ff',
                                   'exists' => 'true'
                                 },
                       'miccmect' => {
                                       'mask' => '0xffffffff',
                                       'exists' => 'true',
                                       'reset' => '0x0',
                                       'number' => '0x7f1'
                                     },
                       'mhpmevent4' => {
                                         'reset' => '0x0',
                                         'exists' => 'true',
                                         'mask' => '0xffffffff'
                                       },
                       'marchid' => {
                                      'reset' => '0x00000011',
                                      'exists' => 'true',
                                      'mask' => '0x0'
                                    },
                       'mitbnd0' => {
                                      'exists' => 'true',
                                      'number' => '0x7d3',
                                      'reset' => '0xffffffff',
                                      'mask' => '0xffffffff'
                                    },
                       'pmpaddr5' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr10' => {
                                        'exists' => 'false'
                                      },
                       'mhpmcounter6' => {
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0',
                                           'exists' => 'true'
                                         },
                       'meipt' => {
                                    'comment' => 'External interrupt priority threshold.',
                                    'mask' => '0xf',
                                    'exists' => 'true',
                                    'number' => '0xbc9',
                                    'reset' => '0x0'
                                  },
                       'mitbnd1' => {
                                      'mask' => '0xffffffff',
                                      'exists' => 'true',
                                      'reset' => '0xffffffff',
                                      'number' => '0x7d6'
                                    },
                       'pmpaddr9' => {
                                       'exists' => 'false'
                                     },
                       'mhpmcounter3h' => {
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0',
                                            'exists' => 'true'
                                          },
                       'mpmc' => {
                                   'mask' => '0x2',
                                   'number' => '0x7c6',
                                   'reset' => '0x2',
                                   'exists' => 'true'
                                 },
                       'mstatus' => {
                                      'mask' => '0x88',
                                      'exists' => 'true',
                                      'reset' => '0x1800'
                                    },
                       'pmpcfg0' => {
                                      'exists' => 'false'
                                    },
                       'mhpmevent6' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'mfdc' => {
                                   'mask' => '0x00071f4d',
                                   'shared' => 'true',
                                   'number' => '0x7f9',
                                   'reset' => '0x00070040',
                                   'exists' => 'true'
                                 },
                       'mdccmect' => {
                                       'exists' => 'true',
                                       'number' => '0x7f2',
                                       'reset' => '0x0',
                                       'mask' => '0xffffffff'
                                     },
                       'pmpaddr12' => {
                                        'exists' => 'false'
                                      },
                       'pmpcfg1' => {
                                      'exists' => 'false'
                                    },
                       'mhpmcounter4' => {
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0',
                                           'exists' => 'true'
                                         },
                       'micect' => {
                                     'exists' => 'true',
                                     'reset' => '0x0',
                                     'number' => '0x7f0',
                                     'mask' => '0xffffffff'
                                   },
                       'mfdhs' => {
                                    'number' => '0x7cf',
                                    'reset' => '0x0',
                                    'exists' => 'true',
                                    'mask' => '0x00000003',
                                    'comment' => 'Force Debug Halt Status'
                                  },
                       'pmpcfg2' => {
                                      'exists' => 'false'
                                    },
                       'meicurpl' => {
                                       'reset' => '0x0',
                                       'number' => '0xbcc',
                                       'exists' => 'true',
                                       'mask' => '0xf',
                                       'comment' => 'External interrupt current priority level.'
                                     },
                       'pmpaddr11' => {
                                        'exists' => 'false'
                                      },
                       'pmpaddr8' => {
                                       'exists' => 'false'
                                     },
                       'mhpmevent5' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'pmpaddr14' => {
                                        'exists' => 'false'
                                      },
                       'dicad1' => {
                                     'debug' => 'true',
                                     'exists' => 'true',
                                     'number' => '0x7ca',
                                     'reset' => '0x0',
                                     'comment' => 'Cache diagnostics.',
                                     'mask' => '0x3'
                                   },
                       'mcountinhibit' => {
                                            'reset' => '0x0',
                                            'poke_mask' => '0x7d',
                                            'exists' => 'true',
                                            'commnet' => 'Performance counter inhibit. One bit per counter.',
                                            'mask' => '0x7d'
                                          },
                       'mip' => {
                                  'reset' => '0x0',
                                  'exists' => 'true',
                                  'poke_mask' => '0x70000888',
                                  'mask' => '0x0'
                                },
                       'mie' => {
                                  'mask' => '0x70000888',
                                  'exists' => 'true',
                                  'reset' => '0x0'
                                },
                       'mhpmcounter5' => {
                                           'mask' => '0xffffffff',
                                           'exists' => 'true',
                                           'reset' => '0x0'
                                         },
                       'dmst' => {
                                   'debug' => 'true',
                                   'exists' => 'true',
                                   'reset' => '0x0',
                                   'number' => '0x7c4',
                                   'comment' => 'Memory synch trigger: Flush caches in debug mode.',
                                   'mask' => '0x0'
                                 },
                       'pmpcfg3' => {
                                      'exists' => 'false'
                                    },
                       'mhartnum' => {
                                       'number' => '0xfc4',
                                       'shared' => 'true',
                                       'reset' => '0x1',
                                       'mask' => '0x0',
                                       'exists' => 'true',
                                       'comment' => 'Hart count'
                                     },
                       'misa' => {
                                   'reset' => '0x40001105',
                                   'exists' => 'true',
                                   'mask' => '0x0'
                                 },
                       'pmpaddr3' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr6' => {
                                       'exists' => 'false'
                                     },
                       'mnmipdel' => {
                                       'comment' => 'NMI pin delegation',
                                       'exists' => 'true',
                                       'mask' => '0x1',
                                       'shared' => 'true',
                                       'number' => '0x7fe',
                                       'reset' => '0x1'
                                     },
                       'mrac' => {
                                   'exists' => 'true',
                                   'comment' => 'Memory region io and cache control.',
                                   'reset' => '0x0',
                                   'shared' => 'true',
                                   'number' => '0x7c0',
                                   'mask' => '0xffffffff'
                                 },
                       'dicad0' => {
                                     'comment' => 'Cache diagnostics.',
                                     'mask' => '0xffffffff',
                                     'exists' => 'true',
                                     'debug' => 'true',
                                     'reset' => '0x0',
                                     'number' => '0x7c9'
                                   },
                       'pmpaddr1' => {
                                       'exists' => 'false'
                                     },
                       'pmpaddr7' => {
                                       'exists' => 'false'
                                     },
                       'dicago' => {
                                     'comment' => 'Cache diagnostics.',
                                     'mask' => '0x0',
                                     'exists' => 'true',
                                     'debug' => 'true',
                                     'number' => '0x7cb',
                                     'reset' => '0x0'
                                   },
                       'mhpmcounter6h' => {
                                            'reset' => '0x0',
                                            'exists' => 'true',
                                            'mask' => '0xffffffff'
                                          },
                       'mfdht' => {
                                    'number' => '0x7ce',
                                    'shared' => 'true',
                                    'reset' => '0x0',
                                    'mask' => '0x0000003f',
                                    'exists' => 'true',
                                    'comment' => 'Force Debug Halt Threshold'
                                  },
                       'pmpaddr4' => {
                                       'exists' => 'false'
                                     },
                       'mvendorid' => {
                                        'reset' => '0x45',
                                        'exists' => 'true',
                                        'mask' => '0x0'
                                      },
                       'mimpid' => {
                                     'reset' => '0x3',
                                     'exists' => 'true',
                                     'mask' => '0x0'
                                   },
                       'meicidpl' => {
                                       'exists' => 'true',
                                       'reset' => '0x0',
                                       'number' => '0xbcb',
                                       'comment' => 'External interrupt claim id priority level.',
                                       'mask' => '0xf'
                                     },
                       'tselect' => {
                                      'exists' => 'true',
                                      'reset' => '0x0',
                                      'mask' => '0x3'
                                    },
                       'mcpc' => {
                                   'exists' => 'true',
                                   'reset' => '0x0',
                                   'number' => '0x7c2',
                                   'comment' => 'Core pause',
                                   'mask' => '0x0'
                                 },
                       'pmpaddr15' => {
                                        'exists' => 'false'
                                      },
                       'pmpaddr0' => {
                                       'exists' => 'false'
                                     }
                     },
            'protection' => {
                              'data_access_enable2' => '1',
                              'data_access_mask4' => '0xffffffff',
                              'inst_access_mask1' => '0x3fffffff',
                              'inst_access_mask7' => '0xffffffff',
                              'data_access_mask6' => '0xffffffff',
                              'inst_access_mask4' => '0xffffffff',
                              'inst_access_enable2' => '1',
                              'data_access_mask7' => '0xffffffff',
                              'inst_access_mask6' => '0xffffffff',
                              'data_access_mask1' => '0x3fffffff',
                              'inst_access_enable1' => '1',
                              'inst_access_addr0' => '0x0',
                              'data_access_enable1' => '1',
                              'data_access_addr0' => '0x0',
                              'inst_access_mask5' => '0xffffffff',
                              'data_access_mask5' => '0xffffffff',
                              'inst_access_addr2' => '0xa0000000',
                              'inst_access_enable6' => '0x0',
                              'data_access_enable4' => '0x0',
                              'data_access_addr3' => '0x80000000',
                              'data_access_enable6' => '0x0',
                              'data_access_addr2' => '0xa0000000',
                              'inst_access_enable4' => '0x0',
                              'inst_access_addr3' => '0x80000000',
                              'data_access_addr4' => '0x00000000',
                              'inst_access_enable5' => '0x0',
                              'inst_access_addr1' => '0xc0000000',
                              'data_access_addr6' => '0x00000000',
                              'inst_access_addr7' => '0x00000000',
                              'data_access_enable5' => '0x0',
                              'inst_access_addr4' => '0x00000000',
                              'inst_access_addr6' => '0x00000000',
                              'data_access_addr7' => '0x00000000',
                              'data_access_addr1' => '0xc0000000',
                              'inst_access_enable3' => '1',
                              'inst_access_mask0' => '0x7fffffff',
                              'data_access_enable3' => '1',
                              'data_access_mask0' => '0x7fffffff',
                              'data_access_enable7' => '0x0',
                              'inst_access_addr5' => '0x00000000',
                              'data_access_addr5' => '0x00000000',
                              'inst_access_enable7' => '0x0',
                              'inst_access_mask2' => '0x1fffffff',
                              'data_access_mask3' => '0x0fffffff',
                              'data_access_enable0' => '1',
                              'data_access_mask2' => '0x1fffffff',
                              'inst_access_mask3' => '0x0fffffff',
                              'inst_access_enable0' => '1'
                            },
            'memmap' => {
                          'serialio' => '0xd0580000',
                          'external_mem_hole' => '0x90000000',
                          'unused_region3' => '0x40000000',
                          'external_data' => '0xc0580000',
                          'unused_region0' => '0x70000000',
                          'unused_region7' => '0x00000000',
                          'unused_region2' => '0x50000000',
                          'external_data_1' => '0xb0000000',
                          'consoleio' => '0xd0580000',
                          'debug_sb_mem' => '0xa0580000',
                          'unused_region5' => '0x20000000',
                          'unused_region4' => '0x30000000',
                          'unused_region6' => '0x10000000',
                          'unused_region1' => '0x60000000'
                        },
            'dccm' => {
                        'dccm_num_banks' => '8',
                        'dccm_eadr' => '0xf004ffff',
                        'dccm_region' => '0xf',
                        'dccm_fdata_width' => 39,
                        'dccm_index_bits' => 11,
                        'dccm_width_bits' => 2,
                        'dccm_ecc_width' => 7,
                        'dccm_offset' => '0x40000',
                        'dccm_data_cell' => 'ram_2048x39',
                        'lsu_sb_bits' => 16,
                        'dccm_enable' => 1,
                        'dccm_data_width' => 32,
                        'dccm_bits' => 16,
                        'dccm_reserved' => '0x2004',
                        'dccm_size_64' => '',
                        'dccm_bank_bits' => 3,
                        'dccm_byte_width' => '4',
                        'dccm_size' => 64,
                        'dccm_sadr' => '0xf0040000',
                        'dccm_rows' => '2048',
                        'dccm_num_banks_8' => ''
                      },
            'pic' => {
                       'pic_meigwclr_offset' => '0x5000',
                       'pic_meigwctrl_offset' => '0x4000',
                       'pic_meip_mask' => '0x0',
                       'pic_bits' => 15,
                       'pic_meip_count' => 4,
                       'pic_meigwctrl_count' => 127,
                       'pic_mpiccfg_count' => 1,
                       'pic_base_addr' => '0xf00c0000',
                       'pic_meip_offset' => '0x1000',
                       'pic_meitp_offset' => '0x1800',
                       'pic_2cycle' => '1',
                       'pic_meipl_mask' => '0xf',
                       'pic_region' => '0xf',
                       'pic_total_int' => 127,
                       'pic_mpiccfg_mask' => '0x1',
                       'pic_meigwctrl_mask' => '0x3',
                       'pic_total_int_plus1' => 128,
                       'pic_meipl_count' => 127,
                       'pic_mpiccfg_offset' => '0x3000',
                       'pic_offset' => '0xc0000',
                       'pic_meigwclr_count' => 127,
                       'pic_meidels_count' => 127,
                       'pic_meigwclr_mask' => '0x0',
                       'pic_meitp_count' => 4,
                       'pic_meidels_mask' => '0x1',
                       'pic_meie_mask' => '0x1',
                       'pic_meitp_mask' => '0x0',
                       'pic_size' => 32,
                       'pic_meie_count' => 127,
                       'pic_meipl_offset' => '0x0000',
                       'pic_meie_offset' => '0x2000',
                       'pic_int_words' => 4
                     },
            'bht' => {
                       'bht_array_depth' => 128,
                       'bht_ghr_hash_1' => '',
                       'bht_addr_hi' => 9,
                       'bht_addr_lo' => '3',
                       'bht_ghr_size' => 7,
                       'bht_ghr_pad' => 'fghr[2:0],3\'b0',
                       'bht_size' => 512,
                       'bht_hash_string' => 0,
                       'bht_ghr_range' => '6:0',
                       'bht_ghr_pad2' => 'fghr[3:0],2\'b0'
                     },
            'config_key' => '32\'hdeadbeef',
            'regwidth' => '32',
            'nmi_vec' => '0x11110000',
            'testbench' => {
                             'ext_datawidth' => '64',
                             'SDVT_AHB' => '1',
                             'RV_TOP' => '`TOP.rvtop',
                             'sterr_rollback' => '0',
                             'ext_addrwidth' => '32',
                             'clock_period' => '100',
                             'CPU_TOP' => '`RV_TOP.swerv',
                             'build_axi_native' => 1,
                             'assert_on' => '',
                             'datawidth' => '64',
                             'lderr_rollback' => '1',
                             'TOP' => 'tb_top',
                             'build_axi4' => 1
                           },
            'target_default' => '1',
            'reset_vec' => '0x80000000',
            'iccm' => {
                        'iccm_eadr' => '0xee00ffff',
                        'iccm_num_banks' => '4',
                        'iccm_bank_index_lo' => 4,
                        'iccm_index_bits' => 12,
                        'iccm_region' => '0xe',
                        'iccm_enable' => 1,
                        'iccm_data_cell' => 'ram_4096x39',
                        'iccm_bank_hi' => 3,
                        'iccm_offset' => '0xe000000',
                        'iccm_num_banks_4' => '',
                        'iccm_rows' => '4096',
                        'iccm_sadr' => '0xee000000',
                        'iccm_size' => 64,
                        'iccm_reserved' => '0x1000',
                        'iccm_size_64' => '',
                        'iccm_bank_bits' => 2,
                        'iccm_bits' => 16
                      },
            'bus' => {
                       'ifu_bus_prty' => '2',
                       'lsu_bus_prty' => '2',
                       'lsu_bus_tag' => '4',
                       'dma_bus_id' => '1',
                       'ifu_bus_tag' => '4',
                       'sb_bus_id' => '1',
                       'ifu_bus_id' => '1',
                       'sb_bus_tag' => '1',
                       'lsu_bus_id' => '1',
                       'dma_bus_tag' => '1',
                       'bus_prty_default' => '3',
                       'dma_bus_prty' => '2',
                       'sb_bus_prty' => '2'
                     },
            'even_odd_trigger_chains' => 'true',
            'num_mmode_perf_regs' => '4',
            'core' => {
                        'bitmanip_zbe' => 0,
                        'lsu_stbuf_depth' => '10',
                        'iccm_only' => 'derived',
                        'div_bit' => '4',
                        'no_iccm_no_icache' => 'derived',
                        'div_new' => 1,
                        'bitmanip_zbs' => 1,
                        'atomic_enable' => '1',
                        'bitmanip_zbc' => 1,
                        'num_threads' => 1,
                        'dma_buf_depth' => '5',
                        'lsu_num_nbload_width' => '3',
                        'bitmanip_zbb' => 1,
                        'lsu_num_nbload' => '8',
                        'icache_only' => 'derived',
                        'bitmanip_zbf' => 0,
                        'bitmanip_zbp' => 0,
                        'timer_legal_en' => '1',
                        'bitmanip_zba' => 1,
                        'bitmanip_zbr' => 0,
                        'iccm_icache' => 1,
                        'fpga_optimize' => 1,
                        'fast_interrupt_redirect' => '1'
                      },
            'perf_events' => [
                               1,
                               2,
                               3,
                               4,
                               5,
                               6,
                               7,
                               8,
                               9,
                               10,
                               11,
                               12,
                               13,
                               14,
                               15,
                               16,
                               17,
                               18,
                               19,
                               20,
                               21,
                               22,
                               23,
                               24,
                               25,
                               26,
                               27,
                               28,
                               29,
                               30,
                               31,
                               32,
                               34,
                               35,
                               36,
                               37,
                               38,
                               39,
                               40,
                               41,
                               42,
                               43,
                               44,
                               45,
                               46,
                               47,
                               48,
                               49,
                               50,
                               51,
                               52,
                               53,
                               54,
                               55,
                               56,
                               512,
                               513,
                               514,
                               515,
                               516
                             ],
            'target' => 'default',
            'tec_rv_icg' => 'clockhdr',
            'max_mmode_perf_event' => '516',
            'harts' => 1,
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
                              'mask' => [
                                          '0x081810c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'poke_mask' => [
                                               '0x081810c7',
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
                              'poke_mask' => [
                                               '0x081810c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'mask' => [
                                          '0x081810c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ]
                            }
                          ],
            'numiregs' => '32',
            'btb' => {
                       'btb_addr_lo' => '3',
                       'btb_fold2_index_hash' => 0,
                       'btb_index3_hi' => 23,
                       'btb_btag_size' => 5,
                       'btb_size' => 512,
                       'btb_toffset_size' => '12',
                       'btb_num_bypass_width' => 4,
                       'btb_index3_lo' => 17,
                       'btb_use_sram' => '0',
                       'btb_btag_fold' => 0,
                       'btb_addr_hi' => 9,
                       'btb_array_depth' => 128,
                       'btb_index1_lo' => '3',
                       'btb_num_bypass' => '8',
                       'btb_index2_hi' => 16,
                       'btb_bypass_enable' => '1',
                       'btb_index2_lo' => 10,
                       'btb_index1_hi' => 9
                     },
            'retstack' => {
                            'ret_stack_size' => '4'
                          },
            'physical' => '1',
            'icache' => {
                          'icache_beat_bits' => 3,
                          'icache_tag_lo' => 13,
                          'icache_num_bypass_width' => 3,
                          'icache_data_index_lo' => 4,
                          'icache_tag_cell' => 'ram_128x25',
                          'icache_size' => 32,
                          'icache_num_beats' => 8,
                          'icache_bank_bits' => 1,
                          'icache_enable' => 1,
                          'icache_data_width' => 64,
                          'icache_waypack' => '1',
                          'icache_num_lines_way' => '128',
                          'icache_beat_addr_hi' => 5,
                          'icache_num_bypass' => '4',
                          'icache_index_hi' => 12,
                          'icache_bank_width' => 8,
                          'icache_scnd_last' => 6,
                          'icache_fdata_width' => 71,
                          'icache_tag_num_bypass' => '2',
                          'icache_bank_hi' => 3,
                          'icache_2banks' => '1',
                          'icache_ecc' => '1',
                          'icache_num_ways' => 4,
                          'icache_tag_bypass_enable' => '1',
                          'icache_data_cell' => 'ram_512x71',
                          'icache_tag_index_lo' => '6',
                          'icache_tag_num_bypass_width' => 2,
                          'icache_bypass_enable' => '1',
                          'icache_tag_depth' => 128,
                          'icache_ln_sz' => 64,
                          'icache_data_depth' => '512',
                          'icache_bank_lo' => 3,
                          'icache_num_lines' => 512,
                          'icache_status_bits' => 3,
                          'icache_banks_way' => 2,
                          'icache_num_lines_bank' => '64'
                        }
          );
1;
