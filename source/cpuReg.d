module cpureg;

import std.stdint;

struct cpuRegisters
{
  // This allows accessing register as:
  // registers.a, registers.f or registers.af
  // So we can access the 8-bit or 16-bit registers 
  struct
  {
    union
    {
      struct
      {
        uint8_t f;
        uint8_t a;
      };

      uint16_t af;
    };
    union
    {
      struct
      {
        uint8_t c;
        uint8_t b;
      };

      uint16_t bc;
    };
    union
    {
      struct
      {
        uint8_t e;
        uint8_t d;
      };

      uint16_t de;
    };
    union
    {
      struct
      {
        uint8_t l;
        uint8_t h;
      };

      uint16_t hl;
    };
  };

  uint16_t sp;
  uint16_t pc;
};

// Flags
alias Flags = uint8_t;
immutable Flags FlagZero = (1 << 7);
immutable Flags FlagNegative = (1 << 6);
immutable Flags FlagHalfCarry = (1 << 5);
immutable Flags FlagCarry = (1 << 4);

cpuRegisters registers;

bool FlagsAreSet(const Flags flags)
{
  return (registers.f & flags) > 0;
}

void SetFlags(const Flags flags)
{
  registers.f |= flags;
}

void ClearFlags(const Flags flags)
{
  registers.f &= ~cast(int) flags;
}
