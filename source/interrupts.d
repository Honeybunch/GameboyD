module interrupts;

import memory;
import cpu;
import std.stdint;

immutable uint16_t InterruptEnableAddress = 0xFFFF;
immutable uint16_t InterruptFlagsAddress = 0xFF0F;

enum Address : uint8_t
{
  VBlank = 0,
  LCDStaus,
  TimerOverflow,
  SerialLink,
  Joypad
};

bool MasterEnable = false;

immutable uint8_t NumOfInterrupts = 5;

immutable uint8_t VBlankFlag = 0b00001;
immutable uint8_t LCDFlag = 0b00010;
immutable uint8_t TimerOverflowFlag = 0b00100;
immutable uint8_t SerialLinkFlag = 0b01000;
immutable uint8_t JoypadFlag = 0b10000;

immutable uint8_t[NumOfInterrupts] InterruptFlags = [
  VBlankFlag, LCDFlag, TimerOverflowFlag, SerialLinkFlag, JoypadFlag
];

immutable uint16_t VBlankISRAddress = 0x0040;
immutable uint16_t LCDStatusISRAddress = 0x0048;
immutable uint16_t TimerOverflowISRAddress = 0x0050;
immutable uint16_t SerialLinkISRAddress = 0x0058;
immutable uint16_t JoypadISRAddress = 0x0060;

immutable uint16_t[NumOfInterrupts] ISRAddresses = [
  VBlankISRAddress, LCDStatusISRAddress, TimerOverflowISRAddress,
  SerialLinkISRAddress, JoypadISRAddress
];

bool TriggerCycleDelay = false;

void Reset()
{
  MasterEnable = false;
  memory.WriteByte(InterruptEnableAddress, 0x00);
  memory.WriteByte(InterruptFlagsAddress, 0x00);
}

void DisableMaster()
{
  MasterEnable = false;
}

void EnableMaster()
{
  MasterEnable = true;
  TriggerCycleDelay = true;
}

void Enable(const Address interruptAddress)
{
  uint8_t interruptsEnabled = memory.ReadByte(InterruptEnableAddress);
  interruptsEnabled |= InterruptFlags[cast(uint8_t)(interruptAddress)];
  memory.WriteByte(InterruptEnableAddress, interruptsEnabled);
}

void Disable(const Address interruptAddress)
{
  uint8_t interruptsEnabled = memory.ReadByte(InterruptEnableAddress);
  interruptsEnabled &= ~cast(int) InterruptFlags[cast(uint8_t)(interruptAddress)];
  memory.WriteByte(InterruptEnableAddress, interruptsEnabled);
}

void Trigger(const Address interruptAddress)
{
  if (MasterEnable == false)
  {
    return;
  }

  const uint8_t interruptFlag = InterruptFlags[cast(uint8_t)(interruptAddress)];

  uint8_t interruptsTriggered = memory.ReadByte(InterruptFlagsAddress);
  interruptsTriggered |= InterruptFlags[cast(uint8_t)(interruptAddress)];
  memory.WriteByte(InterruptFlagsAddress, interruptsTriggered);
}

void RunCycle()
{
  if (MasterEnable == false)
  {
    return;
  }

  // We have to build a one cycle delay into this interrupt handler 
  // Otherwise when the EI instruction is called we may jump immediately
  // to the interrupted instruction
  if (TriggerCycleDelay == true)
  {
    TriggerCycleDelay = false;
    return;
  }

  uint8_t interruptsTriggered = memory.ReadByte(InterruptFlagsAddress);

  if (interruptsTriggered == 0)
  {
    return;
  }

  uint8_t interruptsEnabled = memory.ReadByte(InterruptEnableAddress);

  for (uint8_t i = 0; i < NumOfInterrupts; ++i)
  {
    const uint8_t interruptFlag = InterruptFlags[i];

    // If interrupt was enabled AND triggered, set the PC to the ISR
    if ((interruptsTriggered & interruptsEnabled) && (interruptsTriggered & interruptFlag))
    {

      // Reset the IME so that other interrupts can't trigger
      MasterEnable = false;

      // Push PC to stack
      cpu.registers.sp -= 2;
      memory.WriteShort(cpu.registers.sp, cpu.registers.pc);

      cpu.registers.pc = ISRAddresses[i];

      // Clear interrupt triggered flag
      memory.WriteByte(InterruptFlagsAddress, interruptsTriggered &= ~cast(int) interruptFlag);
    }
  }
}
