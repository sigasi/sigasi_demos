AVR Core Version 8 (Free).

JTAG Programmer is fully compatible with one used in the Atmega128. So you may use Atmel's  JTAG ICE to write/read "flash"(program memory) or "EEPROM".  Free version of the core doesn't include JTAG OCD module.

Synthesis notes:
Please pay special attention at the fact that sate machines in JTAG/OCD part of the design MUST use sequential encoding:

JTAGOCDPrgTop_Inst.OCDProgTCK_Inst.CurrentTAPState[0:15] 
JTAGOCDPrgTop_Inst.OCDProgTCK_Inst.ChipEraseSM_CurrentState[0:3]

If you find any bug don't hesitate to contact me.

Best regards,
Ruslan Lepetenok.



