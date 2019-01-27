module ppu;

import std.stdint;

import memory;
import interrupts;
import cpu;

immutable uint8_t MaxSprites = 40;
immutable uint8_t MaxSpritesPerScanline = 10;

// The size of the buffer that actually gets displayed.
// Useful for creating a buffer that's used by the
// emulator's host.
immutable size_t ScreenWidth = 160;
immutable size_t ScreenHeight = 144;

// The Screen buffer used internally by the Gameboy.
immutable size_t ScreenBufferWidth = 256;
immutable size_t ScreenBufferHeight = 256;
uint8_t[ScreenBufferWidth * ScreenBufferHeight] Screen;

// Unlike CPU registers, PPU registers are "Special Registers" and reside in RAM
// at known offsets. We *could* store these values explicitly as
// references/pointers to the values in the memory block. We could also modify
// the memory read/write routines to point to explicit values that we store
// here. I like this approach because it's more similar to what the actual
// hardware does / I want to keep one contiguous block of memory.
// We store these named addresses here because neither the CPU nor the
// MMU need to know about them.
immutable uint16_t LCDCAddress = 0xFF40; // LCD Control
immutable uint16_t STATAddress = 0xFF41; // LCD Status
immutable uint16_t ScrollYAddress = 0xFF42; //
immutable uint16_t ScrollXAddress = 0xFF43; //
immutable uint16_t LYAddress = 0xFF44; // LCD current vertical line
immutable uint16_t LYCAddress = 0xFF45; // LY Compare address
immutable uint16_t DMAAddress = 0xFF46; //
immutable uint16_t BGPAddress = 0xFF47; // BG and Window color pallette
immutable uint16_t OBP0Address = 0xFF48; // Object pallette 0
immutable uint16_t OBP1Address = 0xFF49; // Object pallette 1
immutable uint16_t WYAddress = 0xFF50; // Window Y position
immutable uint16_t WXAddress = 0xFF51; // Window X position

// Accessors for special registers

uint8_t ReadLCDC()
{
  return memory.ReadByte(LCDCAddress);
}

uint8_t ReadSTAT()
{
  return memory.ReadByte(STATAddress);
}

uint8_t ReadScrollY()
{
  return memory.ReadByte(ScrollYAddress);
}

uint8_t ReadScrollX()
{
  return memory.ReadByte(ScrollXAddress);
}

uint8_t ReadLY()
{
  return memory.ReadByte(LYAddress);
}

uint8_t ReadLYC()
{
  return memory.ReadByte(LYCAddress);
}

uint8_t ReadDMA()
{
  return memory.ReadByte(DMAAddress);
}

uint8_t ReadBGP()
{
  return memory.ReadByte(BGPAddress);
}

uint8_t ReadOBP0()
{
  return memory.ReadByte(OBP0Address);
}

uint8_t ReadOBP1()
{
  return memory.ReadByte(OBP1Address);
}

uint8_t ReadWY()
{
  return memory.ReadByte(WYAddress);
}

uint8_t ReadWX()
{
  return memory.ReadByte(WXAddress);
}

// Mutators for special registers

void WriteLCDC(uint8_t value)
{
  memory.WriteByteInternal(LCDCAddress, value);
}

void WriteSTAT(uint8_t value)
{
  memory.WriteByteInternal(STATAddress, value);
}

void WriteScrollY(uint8_t value)
{
  memory.WriteByteInternal(ScrollYAddress, value);
}

void WriteScrollX(uint8_t value)
{
  memory.WriteByteInternal(ScrollXAddress, value);
}

void WriteLY(uint8_t value)
{
  memory.WriteByteInternal(LYAddress, value);
}

void WriteLYC(uint8_t value)
{
  memory.WriteByteInternal(LYCAddress, value);
}

void WriteDMA(uint8_t value)
{
  memory.WriteByteInternal(DMAAddress, value);
}

void WriteBGPA(uint8_t value)
{
  memory.WriteByteInternal(BGPAddress, value);
}

void WriteOBP0(uint8_t value)
{
  memory.WriteByteInternal(OBP0Address, value);
}

void WriteOBP1(uint8_t value)
{
  memory.WriteByteInternal(OBP1Address, value);
}

void WriteWY(uint8_t value)
{
  memory.WriteByteInternal(WYAddress, value);
}

void WriteWX(uint8_t value)
{
  memory.WriteByteInternal(WXAddress, value);
}

enum LCDMode : uint8_t
{
  HBLANK = 0,
  VBLANK,
  OAM,
  VRAM
};

int16_t ppuCycles;

void SetLCDStatus()
{
  uint8_t lcdControl = ReadLCDC();

  uint8_t lcdStatus = ReadSTAT();

  const(bool) lcdEnabled = (lcdControl & (1 << 7)) > 0;

  if (lcdEnabled == false)
  {
    // Set LCD mode to 1 when disabled
    // Also reset the scanlines
    WriteLY(0);

    lcdStatus &= 252; // Clear all bits but the last 3
    lcdStatus |= (1 << 0); // Set bit 0

    WriteSTAT(lcdStatus);

    return;
  }

  const uint8_t currentLine = ReadLY();
  const LCDMode currentMode = cast(LCDMode)(lcdStatus & 3);

  LCDMode mode = LCDMode.HBLANK;
  uint8_t requiredInterrupt = 0;

  // If we're in VBlank, set mode to 1
  if (currentLine >= 144)
  {
    mode = LCDMode.VBLANK;
    lcdStatus &= ~(1 << 1); // Clear bit 1
    lcdStatus |= (1 << 0); // Set bit 0

    requiredInterrupt = lcdStatus & (1 << 4);
  }
  else
  {
    // Now to determine mode 0, 2 or 3
    const int16_t mode2Bounds = 456 - 80;
    const int16_t mode3Bounds = mode2Bounds - 172;

    // We're in mode 2
    if (ppuCycles >= mode2Bounds)
    {
      mode = LCDMode.OAM;
      lcdStatus |= (1 << 1); // Set bit 1
      lcdStatus &= ~(1 << 0); // Clear bit 0

      requiredInterrupt = lcdStatus & (1 << 5);
    }
    else if (ppuCycles >= mode3Bounds)
    {
      mode = LCDMode.VRAM;
      lcdStatus |= (1 << 1); // Set bit 1
      lcdStatus |= (1 << 0); // Set bit 0
    }
    else
    {
      mode = LCDMode.HBLANK;
      lcdStatus &= ~(1 << 1); // Clear bit 1
      lcdStatus &= ~(1 << 0); // Clear bit 0

      requiredInterrupt = lcdStatus & (1 << 3);
    }
  }

  if (requiredInterrupt && (mode != currentMode))
  {
    interrupts.Trigger(interrupts.Address.LCDStaus);
  }

  // Check coincidence flag
  if (ReadLY() == ReadLYC())
  {
    lcdStatus |= (1 << 2); // Set bit 2
    if (lcdStatus & (1 << 6))
    {
      interrupts.Trigger(interrupts.Address.LCDStaus);
    }
  }
  else
  {
    lcdStatus &= ~(1 << 2); // Clear bit 2
  }

  WriteSTAT(lcdStatus);
}

void Reset()
{
  // Clear the screen
  Screen[0 .. (ScreenBufferWidth * ScreenHeight)] = 0;
}

/*
  Reference:
  http://www.codeslinger.co.uk/pages/projects/gameboy/graphics.html
*/
void RunCycle()
{
  SetLCDStatus();

  uint8_t lcdControl = ReadLCDC();

  uint8_t lcdStatus = ReadSTAT();

  const(bool) lcdEnabled = (lcdControl & (1 << 7)) > 0;

  if (lcdEnabled == false)
  {
    return;
  }

  ppuCycles -= cpu.GetLastTickCyclesCount();

  if (ppuCycles <= 0)
  {
    WriteLY(cast(uint8_t)(ReadLY() + 1));

    const uint8_t currentLine = ReadLY();

    ppuCycles = 456;

    // VBlank
    if (currentLine == ScreenHeight)
    {
      interrupts.Trigger(interrupts.Address.VBlank);
    }
    else if (currentLine > 153)
    {
      WriteLY(0);
    }
    else if (currentLine < ScreenHeight)
    {
      // Render
    }
  }
}
