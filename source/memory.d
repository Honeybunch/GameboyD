module memory;

import std.stdint;
import core.stdc.stdio;

struct MemoryRange
{
  size_t m_start = 0;
  size_t m_end = 0;
}

// 65535 bytes of addressable RAM
immutable size_t memorySize = uint16_t.max + 1;
uint8_t[memorySize] physicalMemory;

immutable MemoryRange cartMemoryRange = {0, 0x7fff};
immutable MemoryRange spirtePatternTableRange = {0x8000, 0x8FFF};
immutable MemoryRange backgroundPatternTableRange = {0x8800, 0x97FF};
immutable MemoryRange ioMemoryRange = {0xFF00, 0xFF7F};

// Used to reset the IO region of memory
immutable size_t ioResetSize = ioMemoryRange.m_end - ioMemoryRange.m_start;
immutable uint8_t[ioResetSize] ioReset = [
  0xCF, 0x00, 0x7C, 0xFF, 0x00, 0x00, 0x00, 0xF8, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0x01, 0x80, 0xBF, 0xF3, 0xFF, 0xBF, 0xFF, 0x3F, 0x00, 0xFF, 0xBF,
  0x7F, 0xFF, 0x9F, 0xFF, 0xBF, 0xFF, 0xFF, 0x00, 0x00, 0xBF, 0x77, 0xF3, 0xF1,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00, 0xFF,
  0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x91,
  0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFC, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x7E,
  0xFF, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x3E, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xC0, 0xFF, 0xC1, 0x00, 0xFE, 0xFF, 0xFF, 0xFF, 0xF8, 0xFF, 0x00, 0x00, 0x00,
  0x8F, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
];

void Reset()
{ // Zero out memory on startup
  physicalMemory[0 .. memorySize] = 0;

  // Reset IO
  physicalMemory[ioMemoryRange.m_start .. ioMemoryRange.m_start + ioResetSize] = ioReset[0 .. ioResetSize];
}

bool LoadRom(uint8_t* rom, size_t romSize)
{
  size_t availableCartSize = cartMemoryRange.m_end + 1;

  if (romSize > availableCartSize)
  {
    printf("Failed to load rom; too large to fit in memory range!\n");
    printf("Size was %zu but max size is %zu", romSize, availableCartSize);
    return false;
  }

  version (DUMP_ROM_DISASM)
  {
    // Dump disassembly to disk
    char* disassembly = new char[INT_MAX];
    size_t disassemblySize = 0;

    for (size_t i = 0; i < romSize; ++i)
    {
      const uint8_t instructionIndex = rom[i];
      ref const instruction inst = instructions[instructionIndex];

      i += inst.m_numParameters;

      const size_t instDisassemblySize = strlen(inst.m_disassembly);

      memcpy(disassembly + disassemblySize, inst.m_disassembly, instDisassemblySize);

      disassemblySize += instDisassemblySize;

      memcpy(disassembly + disassemblySize, "\n", 1);

      disassemblySize++;
    }

    FILE* disasmDumpFile;
    disasmDumpFile = fopen("rom.dump", "w");

    fwrite(disassembly, disassemblySize, 1, disasmDumpFile);

    fclose(disasmDumpFile);

    delete disassembly;
  }

  CopyBlock(0x0000, rom, romSize);
  return true;
}

void CopyBlock(uint16_t address, uint8_t* data, size_t size)
{
  physicalMemory[address .. (address + size)] = data[0 .. size];
}

uint8_t ReadByte(uint16_t address)
{

  // TEMPORARY
  // This is some ad-hoc bullshit to try to handle what the gameboy does
  // when the joypad IO is read. I don't think this is 100% correct yet
  // and it really shouldn't live in this function but it works for now.
  if (address == 0xff00)
  {
    uint8_t joypad = physicalMemory[address];

    uint8_t systemJoypadState = 0xFF;

    joypad ^= 0xFF;

    if (joypad & (1 << 4))
    {
      uint8_t top = systemJoypadState >> 4; // Top nibble
      top |= 0xF0;
      joypad &= top;
    }
    else if (joypad & (1 << 5))
    {
      uint8_t bottom = systemJoypadState & 0xF; // Bottom nibble
      bottom |= 0xF0;
      joypad &= bottom;
    }

    return joypad;
  }

  return physicalMemory[address];
}

void WriteByte(uint16_t address, uint8_t value)
{
  if (address < cartMemoryRange.m_end)
  {
    return;
  }

  if (address == 0xFF41)
  {
    // Special case when writing to LCD Status register
    // The last two bits are read only!

    // Chop off the last two bits of the value
    // 00000101 becomes 00000100
    value &= ~(0b00000011);

    // For the value already in memory, remove all *but* the last two bits and
    // the first bit. The first bit is alway unused and should be left high
    // 10100001 becomes 10000001
    uint8_t currentStat = ReadByte(0xFF41);
    currentStat &= ~(0b01111100);

    // Combine the two values so only the front 6 bits have changed
    // New value should be 00000101
    value |= currentStat;
  }

  physicalMemory[address] = value;
}

void WriteByteInternal(uint16_t address, uint8_t value)
{
  physicalMemory[address] = value;
}

uint16_t ReadShort(uint16_t address)
{
  // This is kinda shady, we get the uint8_t* to the byte at the given address
  // and then cast that uint8_t* to a uint16_t* so we read not just that one
  // byte but also the byte after it.
  return *cast(uint16_t*)(&physicalMemory[address]);
}

void WriteShort(uint16_t address, uint16_t value)
{
  if (address < cartMemoryRange.m_end)
  {
    return;
  }

  // We need to write a short to an address which means writing
  // the first byte of the short to the first byte at the address
  // and the second byte of the short to the second byte of the address.
  physicalMemory[address] = cast(uint8_t)(value & 0x00ff);
  physicalMemory[address + 1] = cast(uint8_t)((value & 0xff00) >> 8);
}

const(uint8_t)* GetMemory()
{
  return &physicalMemory[0];
}
