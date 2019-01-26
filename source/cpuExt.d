module CPUEXT;

import std.stdint;
import core.stdc.stdio;
import CPUREG;
import Platform;

// Extended instructions can't take any parameters
struct instruction
{
  const(char)* m_disassembly = null;
  uint8_t function() m_execution;
};

uint8_t swap_a(); // 0x37
uint8_t bit_3_a(); // 0x5F
uint8_t res_0_a(); // 0x87

const instruction[] extendedInstructions = [{"RCL B     ", null}, // 0x00
{"RCL C     ", null}, // 0x01 
{"RCL D     ", null}, // 0x02
{"RCL E     ", null}, // 0x03
{"RCL H     ", null}, // 0x04
{"RCL L     ", null}, // 0x05
{"RCL (HL)  ", null}, // 0x06
{"RCL A     ", null}, // 0x07
{"RCC B     ", null}, // 0x08
{"RCC C     ", null}, // 0x09
{"RCC D     ", null}, // 0x0A
{"RCC E     ", null}, // 0x0B
{"RCC H     ", null}, // 0x0C
{"RCC L     ", null}, // 0x0D
{"RCC (HL)  ", null}, // 0x0E
{"RCC A     ", null}, // 0x0F
{"RL B      ", null}, // 0x10
{"RL C      ", null}, // 0x11
{"RL D      ", null}, // 0x12
{"RL E      ", null}, // 0x13
{"RL H      ", null}, // 0x14
{"RL L      ", null}, // 0x15
{"RL (HL)   ", null}, // 0x16
{"RR A      ", null}, // 0x17
{"RR B      ", null}, // 0x18
{"RR C      ", null}, // 0x19
{"RR D      ", null}, // 0x1A
{"RR E      ", null}, // 0x1B
{"RR H      ", null}, // 0x1C
{"RR L      ", null}, // 0x1D
{"RR (HL)   ", null}, // 0x1E
{"RR A      ", null}, // 0x1F
{"SLA B     ", null}, // 0x20
{"SLA C     ", null}, // 0x21
{"SLA D     ", null}, // 0x22
{"SLA E     ", null}, // 0x23
{"SLA H     ", null}, // 0x24
{"SLA L     ", null}, // 0x25
{"SLA (HL)  ", null}, // 0x26
{"SLA A     ", null}, // 0x27
{"SRA B     ", null}, // 0x28
{"SRA C     ", null}, // 0x29
{"SRA D     ", null}, // 0x2A
{"SRA E     ", null}, // 0x2B
{"SRA H     ", null}, // 0x2C
{"SRA L     ", null}, // 0x2D
{"SRA (HL)  ", null}, // 0x2E
{"SRA A     ", null}, // 0x2F
{"SWAP B    ", null}, // 0x30
{"SWAP C    ", null}, // 0x31
{"SWAP D    ", null}, // 0x32
{"SWAP E    ", null}, // 0x33
{"SWAP H    ", null}, // 0x34
{"SWAP L    ", null}, // 0x35
{"SWAP (HL) ", null}, // 0x36
{"SWAP A    ", &swap_a}, // 0x37
{"SRL B     ", null}, // 0x38
{"SRL C     ", null}, // 0x39
{"SRL D     ", null}, // 0x3A
{"SRL E     ", null}, // 0x3B
{"SRL H     ", null}, // 0x3C
{"SRL L     ", null}, // 0x3D
{"SRL (HL)  ", null}, // 0x3E
{"SRL A     ", null}, // 0x3F
{"BIT 0,B   ", null}, // 0x40
{"BIT 0,C   ", null}, // 0x41
{"BIT 0,D   ", null}, // 0x42
{"BIT 0,E   ", null}, // 0x43
{"BIT 0,H   ", null}, // 0x44
{"BIT 0,L   ", null}, // 0x45
{"BIT 0,(HL)", null}, // 0x46
{"BIT 0,A   ", null}, // 0x47
{"BIT 1,B   ", null}, // 0x48
{"BIT 1,C   ", null}, // 0x49
{"BIT 1,D   ", null}, // 0x4A
{"BIT 1,E   ", null}, // 0x4B
{"BIT 1,H   ", null}, // 0x4C
{"BIT 1,L   ", null}, // 0x4D
{"BIT 1,(HL)", null}, // 0x4E
{"BIT 1,A   ", null}, // 0x4F
{"BIT 2,B   ", null}, // 0x50
{"BIT 2,C   ", null}, // 0x51
{"BIT 2,D   ", null}, // 0x52
{"BIT 2,E   ", null}, // 0x53
{"BIT 2,H   ", null}, // 0x54
{"BIT 2,L   ", null}, // 0x55
{"BIT 2,(HL)", null}, // 0x56
{"BIT 2,A   ", null}, // 0x57
{"BIT 3,B   ", null}, // 0x58
{"BIT 3,C   ", null}, // 0x59
{"BIT 3,D   ", null}, // 0x5A
{"BIT 3,E   ", null}, // 0x5B
{"BIT 3,H   ", null}, // 0x5C
{"BIT 3,L   ", null}, // 0x5D
{"BIT 3,(HL)", null}, // 0x5E
{"BIT 3,A   ", &bit_3_a}, // 0x5F
{"BIT 4,B   ", null}, // 0x60
{"BIT 4,C   ", null}, // 0x61
{"BIT 4,D   ", null}, // 0x62
{"BIT 4,E   ", null}, // 0x63
{"BIT 4,H   ", null}, // 0x64
{"BIT 4,L   ", null}, // 0x65
{"BIT 4,(HL)", null}, // 0x66
{"BIT 4,A   ", null}, // 0x67
{"BIT 5,B   ", null}, // 0x68
{"BIT 5,C   ", null}, // 0x69
{"BIT 5,D   ", null}, // 0x6A
{"BIT 5,E   ", null}, // 0x6B
{"BIT 5,H   ", null}, // 0x6C
{"BIT 5,L   ", null}, // 0x6D
{"BIT 5,(HL)", null}, // 0x6E
{"BIT 5,A   ", null}, // 0x6F
{"BIT 6,B   ", null}, // 0x70
{"BIT 6,C   ", null}, // 0x71
{"BIT 6,D   ", null}, // 0x72
{"BIT 6,E   ", null}, // 0x73
{"BIT 6,H   ", null}, // 0x74
{"BIT 6,L   ", null}, // 0x75
{"BIT 6,(HL)", null}, // 0x76
{"BIT 6,A   ", null}, // 0x77
{"BIT 7,B   ", null}, // 0x78
{"BIT 7,C   ", null}, // 0x79
{"BIT 7,D   ", null}, // 0x7A
{"BIT 7,E   ", null}, // 0x7B
{"BIT 7,H   ", null}, // 0x7C
{"BIT 7,L   ", null}, // 0x7D
{"BIT 7,(HL)", null}, // 0x7E
{"BIT 7,A   ", null}, // 0x7F
{"RES 0,B   ", null}, // 0x80
{"RES 0,C   ", null}, // 0x81
{"RES 0,D   ", null}, // 0x82
{"RES 0,E   ", null}, // 0x83
{"RES 0,H   ", null}, // 0x84
{"RES 0,L   ", null}, // 0x85
{"RES 0,(HL)", null}, // 0x86
{"RES 0,A   ", &res_0_a}, // 0x87
{"RES 1,B   ", null}, // 0x88
{"RES 1,C   ", null}, // 0x89
{"RES 1,D   ", null}, // 0x8A
{"RES 1,E   ", null}, // 0x8B
{"RES 1,H   ", null}, // 0x8C
{"RES 1,L   ", null}, // 0x8D
{"RES 1,(HL)", null}, // 0x8E
{"RES 1,A   ", null}, // 0x8F
{"RES 2,B   ", null}, // 0x90
{"RES 2,C   ", null}, // 0x91
{"RES 2,D   ", null}, // 0x92
{"RES 2,E   ", null}, // 0x93
{"RES 2,H   ", null}, // 0x94
{"RES 2,L   ", null}, // 0x95
{"RES 2,(HL)", null}, // 0x96
{"RES 2,A   ", null}, // 0x97
{"RES 3,B   ", null}, // 0x98
{"RES 3,C   ", null}, // 0x99
{"RES 3,D   ", null}, // 0x9A
{"RES 3,E   ", null}, // 0x9B
{"RES 3,H   ", null}, // 0x9C
{"RES 3,L   ", null}, // 0x9D
{"RES 3,(HL)", null}, // 0x9E
{"RES 3,A   ", null}, // 0x9F
{"RES 4,B   ", null}, // 0xA0
{"RES 4,C   ", null}, // 0xA1
{"RES 4,D   ", null}, // 0xA2
{"RES 4,E   ", null}, // 0xA3
{"RES 4,H   ", null}, // 0xA4
{"RES 4,L   ", null}, // 0xA5
{"RES 4,(HL)", null}, // 0xA6
{"RES 4,A   ", null}, // 0xA7
{"RES 5,B   ", null}, // 0xA8
{"RES 5,C   ", null}, // 0xA9
{"RES 5,D   ", null}, // 0xAA
{"RES 5,E   ", null}, // 0xAB
{"RES 5,H   ", null}, // 0xAC
{"RES 5,L   ", null}, // 0xAD
{"RES 5,(HL)", null}, // 0xAE
{"RES 5,A   ", null}, // 0xAF
{"RES 6,B   ", null}, // 0xB0
{"RES 6,C   ", null}, // 0xB1
{"RES 6,D   ", null}, // 0xB2
{"RES 6,E   ", null}, // 0xB3
{"RES 6,H   ", null}, // 0xB4
{"RES 6,L   ", null}, // 0xB5
{"RES 6,(HL)", null}, // 0xB6
{"RES 6,A   ", null}, // 0xB7
{"RES 7,B   ", null}, // 0xB8
{"RES 7,C   ", null}, // 0xB9
{"RES 7,D   ", null}, // 0xBA
{"RES 7,E   ", null}, // 0xBB
{"RES 7,H   ", null}, // 0xBC
{"RES 7,L   ", null}, // 0xBD
{"RES 7,(HL)", null}, // 0xBE
{"RES 7,A   ", null}, // 0xBF
{"SET 0,B   ", null}, // 0xC0
{"SET 0,C   ", null}, // 0xC1
{"SET 0,D   ", null}, // 0xC2
{"SET 0,E   ", null}, // 0xC3
{"SET 0,H   ", null}, // 0xC4
{"SET 0,L   ", null}, // 0xC5
{"SET 0,(HL)", null}, // 0xC6
{"SET 0,A   ", null}, // 0xC7
{"SET 1,B   ", null}, // 0xC8
{"SET 1,C   ", null}, // 0xC9
{"SET 1,D   ", null}, // 0xCA
{"SET 1,E   ", null}, // 0xCB
{"SET 1,H   ", null}, // 0xCC
{"SET 1,L   ", null}, // 0xCD
{"SET 1,(HL)", null}, // 0xCE
{"SET 1,A   ", null}, // 0xCF
{"SET 2,B   ", null}, // 0xD0
{"SET 2,C   ", null}, // 0xD1
{"SET 2,D   ", null}, // 0xD2
{"SET 2,E   ", null}, // 0xD3
{"SET 2,H   ", null}, // 0xD4
{"SET 2,L   ", null}, // 0xD5
{"SET 2,(HL)", null}, // 0xD6
{"SET 2,A   ", null}, // 0xD7
{"SET 3,B   ", null}, // 0xD8
{"SET 3,C   ", null}, // 0xD9
{"SET 3,D   ", null}, // 0xDA
{"SET 3,E   ", null}, // 0xDB
{"SET 3,H   ", null}, // 0xDC
{"SET 3,L   ", null}, // 0xDD
{"SET 3,(HL)", null}, // 0xDE
{"SET 3,A   ", null}, // 0xDF
{"SET 4,B   ", null}, // 0xE0
{"SET 4,C   ", null}, // 0xE1
{"SET 4,D   ", null}, // 0xE2
{"SET 4,E   ", null}, // 0xE3
{"SET 4,H   ", null}, // 0xE4
{"SET 4,L   ", null}, // 0xE5
{"SET 4,(HL)", null}, // 0xE6
{"SET 4,A   ", null}, // 0xE7
{"SET 5,B   ", null}, // 0xE8
{"SET 5,C   ", null}, // 0xE9
{"SET 5,D   ", null}, // 0xEA
{"SET 5,E   ", null}, // 0xEB
{"SET 5,H   ", null}, // 0xEC
{"SET 5,L   ", null}, // 0xED
{"SET 5,(HL)", null}, // 0xEE
{"SET 5,A   ", null}, // 0xEF
{"SET 6,B   ", null}, // 0xF0
{"SET 6,C   ", null}, // 0xF1
{"SET 6,D   ", null}, // 0xF2
{"SET 6,E   ", null}, // 0xF3
{"SET 6,H   ", null}, // 0xF4
{"SET 6,L   ", null}, // 0xF5
{"SET 6,(HL)", null}, // 0xF6
{"SET 6,A   ", null}, // 0xF7
{"SET 7,B   ", null}, // 0xF8
{"SET 7,C   ", null}, // 0xF9
{"SET 7,D   ", null}, // 0xFA
{"SET 7,E   ", null}, // 0xFB
{"SET 7,H   ", null}, // 0xFC
{"SET 7,L   ", null}, // 0xFD
{"SET 7,(HL)", null}, // 0xFE
{"SET 7,A   ", null}, // 0xFF
];

uint8_t RunExtendedInstruction(uint8_t instructionIndex)
{
  const(instruction)* extInst = &extendedInstructions[instructionIndex];

  if (extInst.m_execution == null)
  {
    printf("CPU Execution failed! Opcode '%s' not implemented!\n", extInst.m_disassembly);
    Platform.debugBreak();
    return 0;
  }

  return extInst.m_execution();
}

// General Swap
void swap(ref uint8_t value)
{
  // Swap the upper and lower bits of the given value
  value = cast(uint8_t)(cast(int) value << 4) | (cast(int) value >> 4);

  if (value == 0)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }

  ClearFlags(FlagNegative | FlagHalfCarry | FlagCarry);
}

// General bit test
void bit(uint8_t bit, uint8_t value)
{

  uint8_t result = value & (1 << bit);

  if (result == 0)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }

  SetFlags(FlagHalfCarry);
  ClearFlags(FlagNegative);
}

// General bit reset
void res(uint8_t bit, ref uint8_t value)
{
  // No flags need to be adjusted for this
  value &= ~(1 << bit);
}

// 0x37
uint8_t swap_a()
{
  swap(registers.a);
  return 8;
}

// 0x5F
uint8_t bit_3_a()
{
  bit(3, registers.a);
  return 8;
}

// 0x87
uint8_t res_0_a()
{
  res(0, registers.a);
  return 8;
}
