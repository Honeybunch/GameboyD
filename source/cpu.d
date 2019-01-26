module CPU;

import std.stdint;
import std.string;
import std.stdio;
public import CPUREG;
import CPUEXT;
import Memory;
import Interrupts;
import Platform;

version (TRACE)
{
  File disassemblyFile;
}

alias noParam_t = uint8_t function();
alias byteParam_t = uint8_t function(uint8_t);
alias shortParam_t = uint8_t function(uint16_t);

union execution
{
  noParam_t noParam;
  byteParam_t byteParam;
  shortParam_t shortParam;
};

struct instruction
{
  const(char)* m_disassembly = null;
  const uint8_t m_numParameters = 0;
  execution m_execution;
};

uint8_t nop(); // 0x00
uint8_t ld_bc_nn(uint16_t nn); // 0x01
uint8_t ld_bc_a(); // 0x02
uint8_t inc_bc(); // 0x03
uint8_t inc_b(); // 0x04
uint8_t dec_b(); // 0x05
uint8_t ld_b_n(uint8_t n); // 0x06
uint8_t ld_nn_sp(uint16_t nn); // 0x08
uint8_t dec_bc(); // 0x0B
uint8_t inc_c(); // 0x0C
uint8_t dec_c(); // 0x0D
uint8_t ld_c_n(uint8_t n); // 0x0E
uint8_t ld_de_nn(uint16_t nn); // 0x11
uint8_t ld_de_a(); // 0x12
uint8_t inc_de(); // 0x13
uint8_t ld_d_n(uint8_t n); // 0x16
uint8_t jr_n(uint8_t n); // 0x18
uint8_t add_hl_de(); // 0x19
uint8_t ld_a_de(); // 0x1A
uint8_t inc_e(); // 0x1C
uint8_t dec_e(); // 0x1D
uint8_t ld_e_n(uint8_t n); // 0x1E
uint8_t jr_nz_n(uint8_t n); // 0x20
uint8_t ld_hl_nn(uint16_t nn); // 0x21
uint8_t ld_hli_a(); // 0x22
uint8_t inc_hl(); // 0x23
uint8_t jr_z_n(uint8_t n); // 0x28
uint8_t ld_a_hlp(uint16_t nn); // 0x2A
uint8_t inc_l(); // 0x2C
uint8_t cpl(); // 0x2F
uint8_t jr_nc_n(uint8_t n); // 0x30
uint8_t ld_sp_nn(uint16_t nn); // 0x31
uint8_t ld_hld_a(); // 0x32
uint8_t inc_hlp(); // 0x34
uint8_t dec_hlp(); // 0x35
uint8_t ld_hl_n(uint8_t n); // 0x36
uint8_t scf(); // 0x37
uint8_t add_hl_sp(); // 0x39
uint8_t ld_a_hld(); // 0x3A
uint8_t inc_a(); // 0x3C
uint8_t dec_a(); // 0x3D
uint8_t ld_a_n(uint8_t n); // 0x3E
uint8_t ccf(); // 0x3F
uint8_t ld_b_e(); // 0x43
uint8_t ld_b_h(); // 0x44
uint8_t ld_b_a(); // 0x47
uint8_t ld_c_b(); // 0x48
uint8_t ld_c_d(); // 0x4A
uint8_t ld_c_h(); // 0x4C
uint8_t ld_c_hl(); // 0x4E
uint8_t ld_c_a(); // 0x4F
uint8_t ld_d_hl(); // 0x56
uint8_t ld_e_l(); // 0x5D
uint8_t ld_e_hl(); // 0x5E
uint8_t ld_e_a(); // 0x5F
uint8_t ld_h_l(); // 0x65
uint8_t ld_hl_l(); // 0x75
uint8_t ld_a_b(); // 0x78
uint8_t ld_a_c(); // 0x79
uint8_t ld_a_h(); // 0x7C
uint8_t ld_a_hl(); // 0x7E
uint8_t add_a_a(); // 0x87
uint8_t adc_a_e(); // 0x8B
uint8_t adc_a_a(); // 0x8F
uint8_t sub_h(); // 0x94
uint8_t sbc_a_a(); // 0x9F
uint8_t and_c(); // 0xA1
uint8_t and_d(); // 0xA2
uint8_t and_e(); // 0xA3
uint8_t and_h(); // 0xA4
uint8_t and_l(); // 0xA5
uint8_t and_a(); // 0xA7
uint8_t xor_b(); // 0xA8
uint8_t xor_c(); // 0xA9
uint8_t xor_d(); // 0xAA
uint8_t xor_e(); // 0xAB
uint8_t xor_h(); // 0xAC
uint8_t xor_l(); // 0xAD
uint8_t xor_hl(); // 0xAE
uint8_t xor_a(); // 0xAF
uint8_t or_b(); // 0xB0
uint8_t or_c(); // 0xB1
uint8_t cp_a(); // 0xBF
uint8_t ret_nz(); // 0xC0
uint8_t pop_bc(); // 0xC1
uint8_t jp_nn(uint16_t nn); // 0xC3
uint8_t push_bc(); // 0xC5
uint8_t ret_z(); // 0xC8
uint8_t ret(); // 0xC9
uint8_t jp_z_nn(uint16_t nn); // 0xCA
uint8_t cb_n(uint8_t n); // 0xCB
uint8_t call_nn(uint16_t nn); // 0xCD
uint8_t pop_de(); // 0xD1
uint8_t push_de(); // 0xD5
uint8_t reti(); // 0xD9
uint8_t rst_18(); // 0xDF
uint8_t ldh_n_a(uint8_t n); // 0xE0
uint8_t pop_hl(); // 0xE1
uint8_t ld_ff_c_a(); // 0xE2
uint8_t push_hl(); // 0xE5
uint8_t and_n(uint8_t n); // 0xE6
uint8_t jp_hl(); // 0xE9
uint8_t ld_nn_a(uint16_t nn); // 0xEA
uint8_t rst_28(); // 0xEF
uint8_t ldh_a_n(uint8_t n); // 0xF0
uint8_t pop_af(); // 0xF1
uint8_t di(); // 0xF3
uint8_t push_af(); // 0xF5
uint8_t ld_a_nn(uint16_t nn); // 0xFA
uint8_t ei(); // 0xFB
uint8_t cp_n(uint8_t n); // 0xFE
uint8_t rst_38(); // 0xFF

const instruction[] instructions = [ // Cast to noParam_t so the union can properly initialize
{"NOP         ", 0, {&nop}}, // 0x00
{"LD BC d16   ", 2, {cast(noParam_t)(&ld_bc_nn)}}, // 0x01
{"LD (BC) A   ", 0, {&ld_bc_a}}, // 0x02
{"INC BC      ", 0, {&inc_bc}}, // 0x03
{"INC B       ", 0, {&inc_b}}, // 0x04
{"DEC B       ", 0, {&dec_b}}, // 0x05
{"LD B d8     ", 1, {cast(noParam_t)(&ld_b_n)}}, // 0x06
{"RLCA        ", 0, {null}}, // 0x07
{"LD a16 SP   ", 2, {cast(noParam_t)(&ld_nn_sp)}}, // 0x08
{"ADD HL BC   ", 2, {null}}, // 0x09
{"LD A BC     ", 2, {null}}, // 0x0A
{"DEC BC      ", 0, {&dec_bc}}, // 0x0B
{"INC C       ", 0, {cast(noParam_t)(&inc_c)}}, // 0x0C
{"DEC C       ", 0, {cast(noParam_t)(&dec_c)}}, // 0x0D
{"LD C d8     ", 1, {cast(noParam_t)(&ld_c_n)}}, // 0x0E
{"RRCA        ", 0, {null}}, // 0xOF
{"STOP        ", 0, {null}}, // 0x10
{"LD DE d16   ", 2, {cast(noParam_t)(&ld_de_nn)}}, // 0x11
{"LD (DE) A   ", 0, {&ld_de_a}}, // 0x12
{"INC DE      ", 0, {&inc_de}}, // 0x13
{"INC D       ", 0, {null}}, // 0x14
{"DEC D       ", 0, {null}}, // 0x15
{"LD D d8     ", 1, {cast(noParam_t)(&ld_d_n)}}, // 0x16
{"RLA         ", 0, {null}}, // 0x17
{"JR r8       ", 1, {cast(noParam_t)(&jr_n)}}, // 0x18
{"ADD HL DE   ", 0, {&add_hl_de}}, // 0x19
{"LD A (DE)   ", 0, {&ld_a_de}}, // 0x1A
{"DEC DE      ", 0, {null}}, // 0x1B
{"INC E       ", 0, {&inc_e}}, // 0x1C
{"DEC E       ", 0, {&dec_e}}, // 0x1D
{"LD E d8     ", 0, {cast(noParam_t)(&ld_e_n)}}, // 0x1E
{"RRA         ", 0, {null}}, // 0x1F
{"JR NZ r8    ", 1, {cast(noParam_t)(&jr_nz_n)}}, // 0x20
{"LD HL d16   ", 2, {cast(noParam_t)(&ld_hl_nn)}}, // 0x21
{"LD (HL+) A  ", 0, {&ld_hli_a}}, // 0x22
{"INC HL      ", 0, {&inc_hl}}, // 0x23
{"INC H       ", 0, {null}}, // 0x24
{"DEC H       ", 0, {null}}, // 0x25
{"LD H d8     ", 2, {null}}, // 0x26
{"DAA         ", 0, {null}}, // 0x27
{"JR Z r8     ", 1, {cast(noParam_t)(&jr_z_n)}}, // 0x28
{"ADD HL HL   ", 0, {null}}, // 0x29
{"LD A (HL+)  ", 0, {cast(noParam_t)(&ld_a_hlp)}}, // 0x2A
{"DEC HL      ", 0, {null}}, // 0x2B
{"INC L       ", 0, {&inc_l}}, // 0x2C
{"DEC L       ", 0, {null}}, // 0x2D
{"LD L d8     ", 1, {null}}, // 0x2E
{"CPL         ", 0, {&cpl}}, // 0x2F
{"JR NC r8    ", 1, {cast(noParam_t)(&jr_nc_n)}}, // 0x30
{"LD SP d16   ", 2, {cast(noParam_t)(&ld_sp_nn)}}, // 0x31
{"LD (HL-) A  ", 0, {&ld_hld_a}}, // 0x32
{"INC SP      ", 0, {null}}, // 0x33
{"INC (HL)    ", 0, {&inc_hlp}}, // 0x34
{"DEC (HL)    ", 0, {&dec_hlp}}, // 0x35
{"LD (HL) d8  ", 1, {cast(noParam_t)(&ld_hl_n)}}, // 0x36
{"SCF         ", 0, {&scf}}, // 0x37
{"JR C r8     ", 1, {null}}, // 0x38
{"ADD HL SP   ", 0, {&add_hl_sp}}, // 0x39
{"LD A (HL-)  ", 0, {&ld_a_hld}}, // 0x3A
{"DEC SP      ", 0, {null}}, // 0x3B
{"INC A       ", 0, {&inc_a}}, // 0x3C
{"DEC A       ", 0, {&dec_a}}, // 0x3D
{"LD A d8     ", 1, {cast(noParam_t)(&ld_a_n)}}, // 0x3E
{"CCF         ", 0, {&ccf}}, // 0x3F
{"LD B B      ", 0, {&nop}}, // 0x40
{"LD B C      ", 0, {null}}, // 0x41
{"LD B D      ", 0, {null}}, // 0x42
{"LD B E      ", 0, {&ld_b_e}}, // 0x43
{"LD B H      ", 0, {&ld_b_h}}, // 0x44
{"LD B L      ", 0, {null}}, // 0x45
{"LD B (HL)   ", 0, {null}}, // 0x46
{"LD B A      ", 0, {&ld_b_a}}, // 0x47
{"LD C B      ", 0, {&ld_c_b}}, // 0x48
{"LD C C      ", 0, {&nop}}, // 0x49
{"LD C D      ", 0, {&ld_c_d}}, // 0x4A
{"LD C E      ", 0, {null}}, // 0x4B
{"LD C H      ", 0, {&ld_c_h}}, // 0x4C
{"LD C L      ", 0, {null}}, // 0x4D
{"LD C (HL)   ", 0, {&ld_c_hl}}, // 0x4E
{"LD C A      ", 0, {cast(noParam_t)(&ld_c_a)}}, // 0x4F
{"LD D B      ", 0, {null}}, // 0x50
{"LD D C      ", 0, {null}}, // 0x51
{"LD D D      ", 0, {&nop}}, // 0x52
{"LD D E      ", 0, {null}}, // 0x53
{"LD D H      ", 0, {null}}, // 0x54
{"LD D L      ", 0, {null}}, // 0x55
{"LD D (HL)   ", 0, {&ld_d_hl}}, // 0x56
{"LD D A      ", 0, {null}}, // 0x57
{"LD E B      ", 0, {null}}, // 0x58
{"LD E C      ", 0, {null}}, // 0x59
{"LD E D      ", 0, {null}}, // 0x5A
{"LD E E      ", 0, {null}}, // 0x5B
{"LD E H      ", 0, {null}}, // 0x5C
{"LD E L      ", 0, {&ld_e_l}}, // 0x5D
{"LD E (HL)   ", 0, {&ld_e_hl}}, // 0x5E
{"LD E A      ", 0, {&ld_e_a}}, // 0x5F
{"LD H B      ", 0, {null}}, // 0x60
{"LD H C      ", 0, {null}}, // 0x61
{"LD H D      ", 0, {null}}, // 0x62
{"LD H E      ", 0, {null}}, // 0x63
{"LD H H      ", 0, {null}}, // 0x64
{"LD H L      ", 0, {&ld_h_l}}, // 0x65
{"LD H (HL)   ", 0, {null}}, // 0x66
{"LD H A      ", 0, {null}}, // 0x67
{"LD L B      ", 0, {null}}, // 0x68
{"LD L C      ", 0, {null}}, // 0x69
{"LD L D      ", 0, {null}}, // 0x6A
{"LD L E      ", 0, {null}}, // 0x6B
{"LD L H      ", 0, {null}}, // 0x6C
{"LD L L      ", 0, {null}}, // 0x6D
{"LD L (HL)   ", 0, {null}}, // 0x6E
{"LD L A      ", 0, {null}}, // 0x6F
{"LD (HL) B   ", 0, {null}}, // 0x70
{"LD (HL) C   ", 0, {null}}, // 0x71
{"LD (HL) D   ", 0, {null}}, // 0x72
{"LD (HL) E   ", 0, {null}}, // 0x73
{"LD (HL) H   ", 0, {null}}, // 0x74
{"LD (HL) L   ", 0, {&ld_hl_l}}, // 0x75
{"HALT        ", 0, {null}}, // 0x76
{"LD (HL) A   ", 0, {null}}, // 0x77
{"LD A B      ", 0, {&ld_a_b}}, // 0x78
{"LD A C      ", 0, {&ld_a_c}}, // 0x79
{"LD A D      ", 0, {null}}, // 0x7A
{"LD A E      ", 0, {null}}, // 0x7B
{"LD A H      ", 0, {&ld_a_h}}, // 0x7C
{"LD A L      ", 0, {null}}, // 0x7D
{"LD A (HL)   ", 0, {&ld_a_hl}}, // 0x7E
{"LD A A      ", 0, {&nop}}, // 0x7F
{"ADD A B     ", 0, {null}}, // 0x80
{"ADD A C     ", 0, {null}}, // 0x81
{"ADD A D     ", 0, {null}}, // 0x82
{"ADD A E     ", 0, {null}}, // 0x83
{"ADD A H     ", 0, {null}}, // 0x84
{"ADD A L     ", 0, {null}}, // 0x85
{"ADD A (HL)  ", 0, {null}}, // 0x86
{"ADD A A     ", 0, {&add_a_a}}, // 0x87
{"ADC A B     ", 0, {null}}, // 0x88
{"ADC A C     ", 0, {null}}, // 0x89
{"ADC A D     ", 0, {null}}, // 0x8A
{"ADC A E     ", 0, {&adc_a_e}}, // 0x8B
{"ADC A H     ", 0, {null}}, // 0x8C
{"ADC A L     ", 0, {null}}, // 0x8D
{"ADC A (HL)  ", 0, {null}}, // 0x8E
{"ADC A A     ", 0, {&adc_a_a}}, // 0x8F
{"SUB B       ", 0, {null}}, // 0x90
{"SUB C       ", 0, {null}}, // 0x91
{"SUB D       ", 0, {null}}, // 0x92
{"SUB E       ", 0, {null}}, // 0x93
{"SUB H       ", 0, {&sub_h}}, // 0x94
{"SUB L       ", 0, {null}}, // 0x95
{"SUB (HL)    ", 0, {null}}, // 0x96
{"SUB A       ", 0, {null}}, // 0x97
{"SBC A B     ", 0, {null}}, // 0x98
{"SBC A C     ", 0, {null}}, // 0x99
{"SBC A D     ", 0, {null}}, // 0x9A
{"SBC A E     ", 0, {null}}, // 0x9B
{"SBC A H     ", 0, {null}}, // 0x9C
{"SBC A L     ", 0, {null}}, // 0x9D
{"SBC A (HL)  ", 0, {null}}, // 0x9E
{"SBC A A     ", 0, {&sbc_a_a}}, // 0x9F
{"AND B       ", 0, {null}}, // 0xA0
{"AND C       ", 0, {&and_c}}, // 0xA1
{"AND D       ", 0, {&and_d}}, // 0xA2
{"AND E       ", 0, {&and_e}}, // 0xA3
{"AND H       ", 0, {&and_h}}, // 0xA4
{"AND L       ", 0, {&and_l}}, // 0xA5
{"AND (HL)    ", 0, {null}}, // 0xA6
{"AND A       ", 0, {&and_a}}, // 0xA7
{"XOR B       ", 0, {&xor_b}}, // 0xA8
{"XOR C       ", 0, {&xor_c}}, // 0xA9
{"XOR D       ", 0, {&xor_d}}, // 0xAA
{"XOR E       ", 0, {&xor_e}}, // 0xAB
{"XOR H       ", 0, {&xor_h}}, // 0xAC
{"XOR L       ", 0, {&xor_l}}, // 0xAD
{"XOR (HL)    ", 0, {&xor_hl}}, // 0xAE
{"XOR A       ", 0, {&xor_a}}, // 0xAF
{"OR B        ", 0, {&or_b}}, // 0xB0
{"OR C        ", 0, {&or_c}}, // 0xB1
{"OR D        ", 0, {null}}, // 0xB2
{"OR E        ", 0, {null}}, // 0xB3
{"OR H        ", 0, {null}}, // 0xB4
{"OR L        ", 0, {null}}, // 0xB5
{"OR (HL)     ", 0, {null}}, // 0xB6
{"OR A        ", 0, {null}}, // 0xB7
{"CP B        ", 0, {null}}, // 0xB8
{"CP C        ", 0, {null}}, // 0xB9
{"CP D        ", 0, {null}}, // 0xBA
{"CP E        ", 0, {null}}, // 0xBB
{"CP H        ", 0, {null}}, // 0xBC
{"CP L        ", 0, {null}}, // 0xBD
{"CP (HL)     ", 0, {null}}, // 0xBE
{"CP A        ", 0, {&cp_a}}, // 0xBF
{"RET NZ      ", 0, {&ret_nz}}, // 0xC0
{"POP BC      ", 0, {&pop_bc}}, // 0xC1
{"JP NZ a16   ", 2, {null}}, // 0xC2
{"JP a16      ", 2, {cast(noParam_t)(&jp_nn)}}, // 0xC3
{"CALL NZ a16 ", 2, {null}}, // 0xC4
{"PUSH BC     ", 0, {&push_bc}}, // 0xC5
{"ADD A d8    ", 1, {null}}, // 0xC6
{"RST 00      ", 0, {null}}, // 0xC7
{"RET Z       ", 0, {&ret_z}}, // 0xC8
{"RET         ", 0, {&ret}}, // 0xC9
{"JP z a16    ", 2, {cast(noParam_t)(&jp_z_nn)}}, // 0xCA
{"CB N        ", 1, {cast(noParam_t)(&cb_n)}}, // 0xCB
{"CALL Z a16  ", 2, {null}}, // 0xCC
{"CALL a16    ", 2, {cast(noParam_t)(&call_nn)}}, // 0xCD
{"ADC A d8    ", 1, {null}}, // 0xCE
{"RST 08      ", 0, {null}}, // 0xCF
{"RET NC      ", 0, {null}}, // 0xD0
{"POP DE      ", 0, {&pop_de}}, // 0xD1
{"JP NC a16   ", 2, {null}}, // 0xD2
{"UNKNOWN     ", 0, {null}}, // 0xD3
{"CALL NC     ", 0, {null}}, // 0xD4
{"PUSH DE     ", 0, {&push_de}}, // 0xD5
{"SUB d8      ", 1, {null}}, // 0xD6
{"RST 10      ", 0, {null}}, // 0xD7
{"RET C       ", 0, {null}}, // 0xD8
{"RETI        ", 0, {&reti}}, // 0xD9
{"JP C a16    ", 2, {null}}, // 0xDA
{"UNKNOWN     ", 0, {null}}, // 0xDB
{"CALL C a16  ", 2, {null}}, // 0xDC
{"UNKNOWN     ", 0, {null}}, // 0xDD
{"SBC A d8    ", 1, {null}}, // 0xDE
{"RST 18      ", 0, {&rst_18}}, // 0xDF
{"LDH a8 A    ", 1, {cast(noParam_t)(&ldh_n_a)}}, // 0xE0
{"POP HL      ", 0, {&pop_hl}}, // 0xE1
{"LD 0xFF+C A ", 0, {cast(noParam_t)(&ld_ff_c_a)}}, // 0xE2
{"UNKNOWN     ", 0, {null}}, // 0xE3
{"UNKNOWN     ", 0, {null}}, // 0xE4
{"PUSH HL     ", 0, {&push_hl}}, // 0xE5
{"AND d8      ", 1, {cast(noParam_t)(&and_n)}}, // 0xE6
{"RST 20      ", 0, {null}}, // 0xE7
{"ADD SP r8   ", 1, {null}}, // 0xE8
{"JP (HL)     ", 0, {&jp_hl}}, // 0xE9
{"LD a16 A    ", 2, {cast(noParam_t)(&ld_nn_a)}}, // 0xEA
{"UNKNOWN     ", 0, {null}}, // 0xEB
{"UNKNOWN     ", 0, {null}}, // 0xEC
{"UNKNOWN     ", 0, {null}}, // 0xED
{"XOR d8      ", 1, {null}}, // 0xEE
{"RST 28      ", 0, {&rst_28}}, // 0xEF
{"LDH A a8    ", 1, {cast(noParam_t)(&ldh_a_n)}}, // 0xF0
{"POP AF      ", 0, {&pop_af}}, // 0xF1
{"LD A C      ", 0, {null}}, // 0xF2
{"DI          ", 0, {&di}}, // 0xF3
{"UNKNOWN     ", 0, {null}}, // 0xF4
{"PUSH AF     ", 0, {&push_af}}, // 0xF5
{"OR d8       ", 1, {null}}, // 0xF6
{"RST 30      ", 0, {null}}, // 0xF7
{"LD HL SP+r8 ", 1, {null}}, // 0xF8
{"LD SP HL    ", 0, {null}}, // 0xF9
{"LD A a16    ", 2, {cast(noParam_t)(&ld_a_nn)}}, // 0xFA
{"EI          ", 0, {&ei}}, // 0xFB
{"UNKNOWN     ", 0, {null}}, // 0xFC
{"UNKNOWN     ", 0, {null}}, // 0xFD
{"CP d8       ", 1, {cast(noParam_t)(&cp_n)}}, // 0xFE
{"RST 38      ", 0, {&rst_38}}, // 0xFF
];

uint8_t lastTickCycles = 0;
uint64_t totalCycles = 0;

void Reset()
{
  // These are the register values set by the Gameboy's boot rom

  // This value is different depending on the system
  // It can either be 0x01 for the Gameboy or Super Gameboy,
  // 0xFF for the Gameboy Player or 0x11 for the
  // Gameboy Color.
  registers.a = 0x01;
  registers.f = 0xb0;
  registers.b = 0x00;
  registers.c = 0x13;
  registers.d = 0x00;
  registers.e = 0xd8;
  registers.h = 0x01;
  registers.l = 0x4d;
  registers.sp = 0xfffe;
  registers.pc = 0x0100;

  Memory.Reset();

  // These memory values are set by the Gameboy's boot rom
  Memory.WriteByte(0xFF05, 0x00);
  Memory.WriteByte(0xFF06, 0x00);
  Memory.WriteByte(0xFF07, 0x00);
  Memory.WriteByte(0xFF10, 0x80);
  Memory.WriteByte(0xFF11, 0xBF);
  Memory.WriteByte(0xFF12, 0xF3);
  Memory.WriteByte(0xFF14, 0xBF);
  Memory.WriteByte(0xFF16, 0x3F);
  Memory.WriteByte(0xFF17, 0x00);
  Memory.WriteByte(0xFF19, 0xBF);
  Memory.WriteByte(0xFF1A, 0x7F);
  Memory.WriteByte(0xFF1B, 0xFF);
  Memory.WriteByte(0xFF1C, 0x9F);
  Memory.WriteByte(0xFF1E, 0xBF);
  Memory.WriteByte(0xFF20, 0xFF);
  Memory.WriteByte(0xFF21, 0x00);
  Memory.WriteByte(0xFF22, 0x00);
  Memory.WriteByte(0xFF23, 0xBF);
  Memory.WriteByte(0xFF24, 0x77);
  Memory.WriteByte(0xFF25, 0xF3);
  Memory.WriteByte(0xFF26, 0xF1); // or 0xF0 on the Super Game Boy
  Memory.WriteByte(0xFF40, 0x91);
  Memory.WriteByte(0xFF42, 0x00);
  Memory.WriteByte(0xFF43, 0x00);
  Memory.WriteByte(0xFF45, 0x00);
  Memory.WriteByte(0xFF47, 0xFC);
  Memory.WriteByte(0xFF48, 0xFF);
  Memory.WriteByte(0xFF49, 0xFF);
  Memory.WriteByte(0xFF4A, 0x00);
  Memory.WriteByte(0xFF4B, 0x00);
  Memory.WriteByte(0xFFFF, 0x00);

  version (TRACE)
  {
    // Force file to exist
    disassemblyFile = File("rom.trace", "w");
    disassemblyFile.write("");

    disassemblyFile.close();

    // Re-open in append mode
    disassemblyFile = File("rom.trace", "a");
  }
}

version (TRACE)
{
  void DumpMemoryToTrace()
  {
    const uint8_t* memory = Memory.GetMemory();

    string disassembly;

    uint16_t address = 0;
    for (size_t y = 0; y < 4096; ++y)
    {
      if (address < 0x4000)
      {
        disassembly = "ROM0";
      }
      else if (address < 0x8000)
      {
        disassembly = "ROM1";
      }
      else if (address < 0xA000)
      {
        disassembly = "VRA0";
      }
      else if (address < 0xC000)
      {
        disassembly = "SRA0";
      }
      else if (address < 0xD000)
      {
        disassembly = "WRA0";
      }
      else if (address < 0xE000)
      {
        disassembly = "WRA1";
      }
      else if (address < 0xF000)
      {
        disassembly = "ECH0";
      }
      else if (address < 0xFE00)
      {
        disassembly = "ECH1";
      }
      else if (address < 0xFE90)
      {
        disassembly = "OAM ";
      }
      else if (address < 0xFF00)
      {
        disassembly = "----";
      }
      else if (address < 0xFF80)
      {
        disassembly = "I/O ";
      }
      else
      {
        disassembly = "HRAM";
      }

      disassembly = format("%s:%04X ", disassembly, address);

      for (size_t i = 0; i < 16; ++i)
      {
        disassembly = format("%s:%02X ", disassembly, memory[address]);
        address++;
      }

      disassembly = format("%s\n", disassembly);

      disassemblyFile.write(disassembly, disassembly.length, 1);
      disassemblyFile.flush();
    }
  }
}

void RunCycle()
{
  version (TRACE)
  {
    {
      const uint8_t instructionIndex = Memory.ReadByte(registers.pc);
      const(instruction)* inst = &instructions[instructionIndex];

      uint16_t param = 0;

      switch (inst.m_numParameters)
      {
      case 1:
        {
          uint8_t param8 = Memory.ReadByte(cast(uint16_t)(registers.pc + 1));
          param = param8;
          break;
        }
      case 2:
        {
          uint16_t param16 = Memory.ReadShort(cast(uint16_t)(registers.pc + 1));
          param = param16;
          break;
        }
      default:
        break;
      }

      string disassembly = format("PC:%04X  ", registers.pc);

      if (inst.m_numParameters == 0)
      {
        disassembly = format("%s %s     ", disassembly, inst.m_disassembly);
      }
      else if (inst.m_numParameters == 1)
      {
        disassembly = format("%s %s %02X  ", disassembly, inst.m_disassembly, param);
      }
      else if (inst.m_numParameters == 2)
      {
        disassembly = format("%s %s %04X", disassembly, inst.m_disassembly, param);
      }

      disassembly = format("%s  AF:%04X", disassembly, registers.af);

      disassembly = format("%s  BC:%04X", disassembly, registers.bc);

      disassembly = format("%s  DE:%04X", disassembly, registers.de);

      disassembly = format("%s  HL:%04X", disassembly, registers.hl);

      disassembly = format("%s  SP:%04X", disassembly, registers.sp);

      disassembly = format("%s      ", disassembly);

      // Print flags
      if (FlagsAreSet(FlagZero))
      {
        disassembly = format("%s Z", disassembly);
      }
      else
      {
        disassembly = format("%s -", disassembly);
      }

      if (FlagsAreSet(FlagNegative))
      {
        disassembly = format("%s N", disassembly);
      }
      else
      {
        disassembly = format("%s -", disassembly);
      }

      if (FlagsAreSet(FlagHalfCarry))
      {
        disassembly = format("%s H", disassembly);
      }
      else
      {
        disassembly = format("%s -", disassembly);
      }

      if (FlagsAreSet(FlagCarry))
      {
        disassembly = format("%s C", disassembly);
      }
      else
      {
        disassembly = format("%s -", disassembly);
      }

      disassembly = format("%s\tff40: %02X ff41: %02X", disassembly,
          Memory.ReadByte(0xFF40), Memory.ReadByte(0xFF41));

      disassembly = format("%s\n", disassembly);

      disassemblyFile.write(disassembly);

      disassemblyFile.flush();
    }
  }

  // Fetch opcode
  const uint8_t instructionIndex = Memory.ReadByte(registers.pc++);

  const(instruction)* inst = &instructions[instructionIndex];

  if (inst.m_execution.noParam == null)
  {
    printf("CPU Execution failed! Opcode '%s' not implemented!\n", inst.m_disassembly);
    Platform.debugBreak();
    return;
  }

  uint16_t param = 0;

  // Decode & Execute opcode
  switch (inst.m_numParameters)
  {
  case 0:
    {
      lastTickCycles = inst.m_execution.noParam();

      break;
    }
  case 1:
    {
      uint8_t param8 = Memory.ReadByte(registers.pc);
      param = param8;

      registers.pc++;

      lastTickCycles = inst.m_execution.byteParam(param8);

      break;
    }
  case 2:
    {
      uint16_t param16 = Memory.ReadShort(registers.pc);
      param = param16;

      registers.pc += 2;

      lastTickCycles = inst.m_execution.shortParam(param16);

      break;
    }
  default:
    {
      printf("Failed to decode opcode! number of parameters for the instruction " ~ "was invalid '%d'",
          inst.m_numParameters);
      Platform.debugBreak();
      break;
    }
  }

  totalCycles += lastTickCycles;
}

uint8_t GetLastTickCyclesCount()
{
  return lastTickCycles;
}

uint64_t GetTotalCyclesCount()
{
  return totalCycles;
}

// Some common helper functions

// General xor
void common_xor(uint8_t value)
{
  registers.a ^= value;

  if (registers.a == 0)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }

  ClearFlags(FlagNegative | FlagHalfCarry | FlagCarry);
}

// General or
void common_or(const uint8_t value)
{
  registers.a |= value;

  if (registers.a == 0)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }

  ClearFlags(FlagNegative | FlagHalfCarry | FlagCarry);
}

// General and
void common_and(const uint8_t value)
{
  registers.a &= value;

  if (registers.a == 0)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }

  ClearFlags(FlagNegative | FlagCarry);
  SetFlags(FlagHalfCarry);
}

// General add carry
void adc(uint8_t value)
{
  // If the carry flag is set, add one to the incoming value
  value += FlagsAreSet(FlagCarry) ? 1 : 0;

  // Calculate the result into a 16 bit value so we can check for overflows
  uint16_t result = registers.a + value;

  // If there is a value in the higher nibble, our math overflowed
  // outside the range of 8 bits; we need to set the carry flag
  if ((result & 0xff00) > 0)
  {
    SetFlags(FlagCarry);
  }
  else
  {
    ClearFlags(FlagCarry);
  }

  // If the incoming value (plus the carry flag we added above) is the same
  // as the A register value, set the 0 flag
  if (value == registers.a)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }

  // If the sum of lower nibble of the incoming value and the value in
  // register A can't be stored in 4 bits, set the HalfCarry flag
  if ((value & 0x0f) + (registers.a & 0x0f) > 0x0f)
  {
    SetFlags(FlagHalfCarry);
  }
  else
  {
    ClearFlags(FlagHalfCarry);
  }

  SetFlags(FlagNegative);

  // Store the lower 8 bits in register a
  registers.a = uint8_t(result & 0xff);
}

// General 8-bit add
void add(ref uint8_t lhs, uint8_t rhs)
{
  // Store add result in a 16 bit value so we can check for overflows
  uint16_t result = lhs + rhs;

  // If there's any value in the upper 8 bits we overflowed and
  // need to set the carry flag
  if ((result & 0xff00) > 0)
  {
    SetFlags(FlagCarry);
  }
  else
  {
    ClearFlags(FlagCarry);
  }

  // Store the result as a byte
  lhs = uint8_t(result & 0xff);

  if (lhs == 0)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }

  // Check for a half carry
  if ((lhs & 0xf) + (rhs & 0xf) > 0xf)
  {
    SetFlags(FlagHalfCarry);
  }
  else
  {
    ClearFlags(FlagHalfCarry);
  }

  // Always clear the negative flag
  ClearFlags(FlagNegative);
}

// General 16-bit add
void add16(ref uint16_t lhs, uint16_t rhs)
{
  // Store add result in a 32 bit value so we can check for overflows
  uint32_t result = lhs + rhs;

  // If there's any value in the upper 16 bits we overflowed and
  // need to set the carry flag
  if ((result & 0xffff0000) > 0)
  {
    SetFlags(FlagCarry);
  }
  else
  {
    ClearFlags(FlagCarry);
  }

  // Store the result as a short
  lhs = uint16_t(result & 0xffff);

  // Check for a half carry
  if ((lhs & 0xf) + (rhs & 0xf) > 0xf)
  {
    SetFlags(FlagHalfCarry);
  }
  else
  {
    ClearFlags(FlagHalfCarry);
  }

  // Ignore the Zero flag but clear the Negative flag
  ClearFlags(FlagNegative);
}

// General subtract carry
void sbc(uint8_t value)
{
  // If the carry flag is set, add one to the incoming value
  value += FlagsAreSet(FlagCarry) ? 1 : 0;

  // If the incoming value is greater than value in register A
  // We're going to underflow so set the carry flag
  if (value > registers.a)
  {
    SetFlags(FlagCarry);
  }
  else
  {
    ClearFlags(FlagCarry);
  }

  // If the incoming value (plus the carry flag we added above) is the same
  // as the A register value, set the 0 flag since register A will be 0
  if (value == registers.a)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }

  // If the sum of lower nibble of the incoming value and the value in
  // register A can't be stored in 4 bits, set the HalfCarry flag
  if ((value & 0x0f) + (registers.a & 0x0f) > 0x0f)
  {
    SetFlags(FlagHalfCarry);
  }
  else
  {
    ClearFlags(FlagHalfCarry);
  }

  SetFlags(FlagNegative);

  registers.a -= value;
}

// General subtraction
void sub(uint8_t value)
{
  SetFlags(FlagNegative);

  if (value > registers.a)
  {
    SetFlags(FlagCarry);
  }
  else
  {
    ClearFlags(FlagCarry);
  }

  if ((value & 0x0f) > (registers.a & 0x0f))
  {
    SetFlags(FlagHalfCarry);
  }
  else
  {
    ClearFlags(FlagHalfCarry);
  }

  registers.a -= value;

  if (registers.a == 0)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }
}

// General 8-bit increment
void inc(ref uint8_t value)
{
  // Check for a half carry first
  if ((value & 0xf) == 0xf)
  {
    SetFlags(FlagHalfCarry);
  }
  else
  {
    ClearFlags(FlagHalfCarry);
  }

  value++;

  // Check if we've wrapped back to 0
  if (value == 0)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }

  // Ignore the Carry flag

  // Always clear Negative flag
  ClearFlags(FlagNegative);
}

// General 8-bit decrement
void dec(ref uint8_t value)
{
  // Check for a half carry first
  if ((value & 0xf) > 0)
  {
    ClearFlags(FlagHalfCarry);
  }
  else
  {
    SetFlags(FlagHalfCarry);
  }

  value--;

  // Check if we've bottomed out to 0
  if (value == 0)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }

  // Ignore the Carry flag

  // Always set Negative flag
  SetFlags(FlagNegative);
}

// General Compare
// This has checks and sets all the flags that a subtraction would perform
// but does not modify the A register.
void cp(uint8_t value)
{
  SetFlags(FlagNegative);

  // If the incoming value is the same as the A register
  // the result would be a zero if they were subtracted
  if (registers.a == value)
  {
    SetFlags(FlagZero);
  }
  else
  {
    ClearFlags(FlagZero);
  }

  // If the incoming value is larger than the A register
  // this would set the carry flag during a subtraction
  if (value > registers.a)
  {
    SetFlags(FlagCarry);
  }
  else
  {
    ClearFlags(FlagCarry);
  }

  // Same half-carry rules as a subtraction
  if ((value & 0x0f) > (registers.a & 0x0f))
  {
    SetFlags(FlagHalfCarry);
  }
  else
  {
    ClearFlags(FlagHalfCarry);
  }
}

void pushToStack(uint16_t value)
{
  registers.sp -= 2;
  Memory.WriteShort(registers.sp, value);
}

uint16_t popFromStack()
{
  uint16_t result = Memory.ReadShort(registers.sp);
  registers.sp += 2;

  return result;
}

// General Reset
void rst(const uint16_t value)
{
  pushToStack(registers.pc);
  registers.pc = value;
}

// 0x00
uint8_t nop()
{
  return 4;
}

// 0x01
uint8_t ld_bc_nn(uint16_t nn)
{
  // Load nn to the bc register
  registers.bc = nn;

  return 12;
}

// 0x02
uint8_t ld_bc_a()
{
  // Load the value at register A into the position at the address in register
  // BC
  Memory.WriteByte(registers.bc, registers.a);
  return 8;
}

// 0x03
uint8_t inc_bc()
{
  registers.bc++;
  return 8;
}

// 0x04
uint8_t inc_b()
{
  inc(registers.b);
  return 4;
}

// 0x05
uint8_t dec_b()
{
  dec(registers.b);
  return 4;
}

// 0x06
uint8_t ld_b_n(uint8_t n)
{
  // Load the given value n into register B
  registers.b = n;
  return 8;
}

// 0x08
uint8_t ld_nn_sp(uint16_t nn)
{
  Memory.WriteShort(nn, registers.sp);
  return 20;
}

// 0x0B
uint8_t dec_bc()
{
  // No need to set flags
  registers.bc--;
  return 8;
}

// 0x0C
uint8_t inc_c()
{
  inc(registers.c);
  return 4;
}

// 0x0D
uint8_t dec_c()
{
  dec(registers.c);
  return 4;
}

// 0x0E
uint8_t ld_c_n(uint8_t n)
{
  // Load the given value n into register C
  registers.c = n;

  return 8;
}

// 0x11
uint8_t ld_de_nn(uint16_t nn)
{
  // Load nn to the de register
  registers.de = nn;

  return 12;
}

// 0x12
uint8_t ld_de_a()
{
  // Load the value at register A into the position at the address in register
  // DE
  Memory.WriteByte(registers.de, registers.a);
  return 8;
}

// 0x13
uint8_t inc_de()
{
  registers.de++;
  return 8;
}

// 0x16
uint8_t ld_d_n(uint8_t n)
{
  // Load the given value n into register D
  registers.d = n;

  return 8;
}

// 0x18
uint8_t jr_n(uint8_t n)
{
  registers.pc += cast(int8_t)(n);
  return 12;
}

// 0x19
uint8_t add_hl_de()
{
  add16(registers.hl, registers.de);
  return 8;
}

// 0x1A
uint8_t ld_a_de()
{
  registers.a = Memory.ReadByte(registers.de);
  return 8;
}

// 0x1C
uint8_t inc_e()
{
  inc(registers.e);
  return 4;
}

// 0x1D
uint8_t dec_e()
{
  dec(registers.e);
  return 4;
}

// 0x1E
uint8_t ld_e_n(uint8_t n)
{
  registers.e = n;
  return 8;
}

// 0x20
uint8_t jr_nz_n(uint8_t n)
{
  if (!FlagsAreSet(FlagZero))
  {
    registers.pc += cast(int8_t)(n);

    return 12;
  }

  return 8;
}

// 0x21
uint8_t ld_hl_nn(uint16_t nn)
{
  // Load the given value nn into the position at the address in register HL
  registers.hl = nn;
  return 12;
}

// 0x22
uint8_t ld_hli_a()
{
  Memory.WriteByte(registers.hl, registers.a);
  registers.hl++;
  return 8;
}

// 0x23
uint8_t inc_hl()
{
  registers.hl++;
  return 8;
}

// 0x28
uint8_t jr_z_n(uint8_t n)
{
  if (FlagsAreSet(FlagZero))
  {
    registers.pc += cast(int8_t)(n);

    return 12;
  }

  return 8;
}

// 0x2A
uint8_t ld_a_hlp(uint16_t nn)
{
  registers.a = Memory.ReadByte(registers.hl++);
  return 8;
}

// 0x2C
uint8_t inc_l()
{
  inc(registers.l);
  return 4;
}

// 0x2F
uint8_t cpl()
{
  // Invert all bits of the A register
  registers.a = cast(uint8_t)(~cast(int) registers.a);

  // Set Negative and Half Carry flags
  SetFlags(FlagNegative | FlagHalfCarry);

  return 4;
}

// 0x30
uint8_t jr_nc_n(uint8_t n)
{
  if (!FlagsAreSet(FlagCarry))
  {
    registers.pc += cast(int8_t)(n);

    return 12;
  }

  return 8;
}

// 0x31
uint8_t ld_sp_nn(uint16_t nn)
{
  registers.sp = nn;
  return 12;
}

// 0x32
uint8_t ld_hld_a()
{
  // Load the value in register A into the position at the address in register
  // HL. Then decrement HL
  Memory.WriteByte(registers.hl, registers.a);
  registers.hl--;

  return 8;
}
// 0x34
uint8_t inc_hlp()
{
  uint8_t value = Memory.ReadByte(registers.hl);

  // Call inc to make sure flags are set appropriately
  inc(value);

  Memory.WriteByte(registers.hl, value);

  return 12;
}

// 0x35
uint8_t dec_hlp()
{
  uint8_t value = Memory.ReadByte(registers.hl);

  // Call dec to make sure flags are set appropriately
  dec(value);

  Memory.WriteByte(registers.hl, value);

  return 12;
}

// 0x36
uint8_t ld_hl_n(uint8_t n)
{
  Memory.WriteByte(registers.hl, n);
  return 12;
}

// 0x37
uint8_t scf()
{
  // Set Carry Flag instruction
  // Also clear the Negative and Half Carry flags
  SetFlags(FlagCarry);
  ClearFlags(FlagNegative | FlagHalfCarry);
  return 4;
}

// 0x39
uint8_t add_hl_sp()
{
  add16(registers.hl, registers.sp);
  return 8;
}

// 0x3A
uint8_t ld_a_hld()
{
  registers.a = Memory.ReadByte(registers.hl);
  registers.hl--;
  return 8;
}

// 0x3C
uint8_t inc_a()
{
  inc(registers.a);
  return 4;
}

// 0x3D
uint8_t dec_a()
{
  dec(registers.a);
  return 4;
}

// 0x3F
uint8_t ld_a_n(uint8_t n)
{
  // Load the given value into register A
  registers.a = n;

  return 8;
}

// 0x3F
uint8_t ccf()
{
  // This inverts the carry flag and clears the half carry and negative flags
  // The zero flag is ignored

  // On the Z80 the HalfCarry flag is also inverted but not on the Gameboy

  if (FlagsAreSet(FlagCarry))
  {
    ClearFlags(FlagCarry);
  }
  else
  {
    SetFlags(FlagCarry);
  }

  ClearFlags(FlagHalfCarry | FlagNegative);

  return 4;
}

// 0x43
uint8_t ld_b_e()
{
  registers.b = registers.e;
  return 4;
}

// 0x44
uint8_t ld_b_h()
{
  registers.b = registers.h;
  return 4;
}

// 0x47
uint8_t ld_b_a()
{
  registers.b = registers.a;
  return 4;
}

// 0x48
uint8_t ld_c_b()
{
  registers.c = registers.b;
  return 4;
}

// 0x4A
uint8_t ld_c_d()
{
  registers.c = registers.d;
  return 4;
}

// 0x4C
uint8_t ld_c_h()
{
  registers.c = registers.h;
  return 4;
}

// 0x4E
uint8_t ld_c_hl()
{
  registers.c = Memory.ReadByte(registers.hl);
  return 8;
}

// 0x4F
uint8_t ld_c_a()
{
  registers.c = registers.a;
  return 4;
}

// 0x56
uint8_t ld_d_hl()
{
  registers.d = Memory.ReadByte(registers.hl);
  return 8;
}

// 0x5D
uint8_t ld_e_l()
{
  registers.e = registers.l;
  return 4;
}

// 0x5E
uint8_t ld_e_hl()
{
  registers.e = Memory.ReadByte(registers.hl);
  return 8;
}

// 0x5F
uint8_t ld_e_a()
{
  registers.e = registers.a;
  return 4;
}

// 0x65
uint8_t ld_h_l()
{
  registers.h = registers.l;
  return 4;
}

// 0x75
uint8_t ld_hl_l()
{
  Memory.WriteByte(registers.hl, registers.l);
  return 8;
}

// 0x78
uint8_t ld_a_b()
{
  registers.a = registers.b;
  return 4;
}

// 0x79
uint8_t ld_a_c()
{
  registers.a = registers.b;
  return 4;
}

// 0x7C
uint8_t ld_a_h()
{
  registers.a = registers.h;
  return 4;
}

// 0x7E
uint8_t ld_a_hl()
{
  registers.a = Memory.ReadByte(registers.hl);
  return 8;
}

// 0x7F
uint8_t ld_a_a()
{
  // Essentially just a NOP
  return 4;
}

// 0x87
uint8_t add_a_a()
{
  add(registers.a, registers.a);
  return 4;
}

// 0x8B
uint8_t adc_a_e()
{
  adc(registers.e);
  return 4;
}

// 0x8F
uint8_t adc_a_a()
{
  adc(registers.a);
  return 4;
}

// 0x94
uint8_t sub_h()
{
  sub(registers.h);
  return 4;
}

// 0x9F
uint8_t sbc_a_a()
{
  sbc(registers.a);
  return 4;
}

// 0xA1
uint8_t and_c()
{
  common_and(registers.c);
  return 4;
}

// 0xA2
uint8_t and_d()
{
  common_and(registers.d);
  return 4;
}

// 0xA3
uint8_t and_e()
{
  common_and(registers.e);
  return 4;
}

// 0xA4
uint8_t and_h()
{
  common_and(registers.h);
  return 4;
}

// 0xA5
uint8_t and_l()
{
  common_and(registers.l);
  return 4;
}

// 0xA7
uint8_t and_a()
{
  common_and(registers.a);
  return 4;
}

// 0xA8
uint8_t xor_b()
{
  common_xor(registers.b);
  return 4;
}

// 0xA9
uint8_t xor_c()
{
  common_xor(registers.c);
  return 4;
}

// 0xAA
uint8_t xor_d()
{
  common_xor(registers.d);
  return 4;
}

// 0xAB
uint8_t xor_e()
{
  common_xor(registers.e);
  return 4;
}

// 0xAC
uint8_t xor_h()
{
  common_xor(registers.h);
  return 4;
}

// 0xAD
uint8_t xor_l()
{
  common_xor(registers.l);
  return 4;
}

// 0xAE
uint8_t xor_hl()
{
  common_xor(Memory.ReadByte(registers.hl));
  return 8;
}

// 0xAF
uint8_t xor_a()
{
  common_xor(registers.a);
  return 4;
}

// 0xB0
uint8_t or_b()
{
  common_or(registers.b);
  return 4;
}

// 0xB1
uint8_t or_c()
{
  common_or(registers.c);
  return 4;
}

// 0xBF
uint8_t cp_a()
{
  cp(registers.a);
  return 4;
}

// 0xC0
uint8_t ret_nz()
{
  // If the Z flag is 0, return from the current function.
  // This is done by reading the value at the top of the stack
  // and setting the program counter equal to that value;
  if (!FlagsAreSet(FlagZero))
  {
    registers.pc = popFromStack();
    return 20;
  }

  // Otherwise do nothing
  return 8;
}

// 0xC1
uint8_t pop_bc()
{
  registers.bc = popFromStack();
  return 12;
}

// 0xC3
uint8_t jp_nn(uint16_t nn)
{
  // Jump the PC to the given 16 bit address
  registers.pc = nn;

  return 16;
}

// 0xC5
uint8_t push_bc()
{
  pushToStack(registers.bc);
  return 16;
}

// 0xC8
uint8_t ret_z()
{

  // Return if the Zero flag is set
  // otherwise do nothing
  if (FlagsAreSet(FlagZero))
  {
    registers.pc = popFromStack();
    return 20;
  }

  return 8;
}

// 0xC9
uint8_t ret()
{
  // Read a short on the stack and store it in the program counter
  registers.pc = popFromStack();
  return 16;
}

// 0xCA
uint8_t jp_z_nn(uint16_t nn)
{
  // If the Z flag is set, jump to the given address
  if (FlagsAreSet(FlagZero))
  {
    registers.pc = nn;
    return 16;
  }

  // Otherwise do nothing
  return 12;
}

// 0xCB
uint8_t cb_n(uint8_t n)
{
  // Fetches instruction n from the extended instruction table and executes it
  // The "4" is the fetch cycles represented by this instruction
  return cast(uint8_t)(4 + CPUEXT.RunExtendedInstruction(n));
}

// 0xCD
uint8_t call_nn(uint16_t nn)
{
  // Store the PC on the stack so we can pop it off later
  pushToStack(registers.pc);

  // Set the PC to the address we want to call to
  registers.pc = nn;

  return 24;
}

// 0xD1
uint8_t pop_de()
{
  registers.de = popFromStack();
  return 12;
}

// 0xD5
uint8_t push_de()
{
  pushToStack(registers.de);
  return 16;
}

// 0xD9
uint8_t reti()
{
  Interrupts.EnableMaster();
  return ret();
}

// 0xDF
uint8_t rst_18()
{
  rst(0x18);
  return 16;
}

// 0xE0
uint8_t ldh_n_a(uint8_t n)
{
  Memory.WriteByte(0xFF00 + n, registers.a);
  return 12;
}

uint8_t pop_hl()
{
  registers.hl = popFromStack();
  return 12;
}

// 0xE2
uint8_t ld_ff_c_a()
{
  Memory.WriteByte(0xFF00 + registers.c, registers.a);
  return 8;
}

// 0xE5
uint8_t push_hl()
{
  pushToStack(registers.hl);
  return 16;
}

// 0xE6
uint8_t and_n(uint8_t n)
{
  common_and(n);
  return 8;
}

// 0xE9
uint8_t jp_hl()
{
  // Jump the PC to the 16 bit value stored in register hl
  registers.pc = registers.hl;
  return 4;
}

// 0xEA
uint8_t ld_nn_a(uint16_t nn)
{
  Memory.WriteByte(nn, registers.a);
  return 16;
}

// 0xEF
uint8_t rst_28()
{
  rst(0x28);
  return 16;
}

// 0xF0
uint8_t ldh_a_n(uint8_t n)
{
  registers.a = Memory.ReadByte(0xFF00 + n);
  return 12;
}

// 0xF1
uint8_t pop_af()
{
  registers.af = popFromStack();
  return 12;
}

// 0xF3
uint8_t di()
{
  // Disable interupts
  Interrupts.DisableMaster();
  return 4;
}

// 0xF5
uint8_t push_af()
{
  pushToStack(registers.af);
  return 16;
}

// 0xFA
uint8_t ld_a_nn(uint16_t nn)
{
  registers.a = Memory.ReadByte(nn);
  return 16;
}

// 0xFB
uint8_t ei()
{
  // Enable interupts
  Interrupts.EnableMaster();
  return 4;
}

// 0xFE
uint8_t cp_n(uint8_t n)
{
  cp(n);
  return 8;
}

// 0xFF
uint8_t rst_38()
{
  rst(0x38);
  return 16;
}
