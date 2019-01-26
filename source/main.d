import std.stdint;
import std.file;
import core.stdc.stdio;

import CPU;
import PPU;
import Interrupts;
import Memory;
import TWM;

/// Result of the application
enum Result
{
  Success,
  FailedToOpenRomFile,
  FailedToReadRomFile,
  FailedToLoadRom,
}

int main()
{
  TWM.Window* window = new TWM.Window();
  TWM.ConstructWindow(PPU.ScreenWidth * 4, PPU.ScreenHeight * 4, window);

  uint8_t[] rom = cast(uint8_t[])(std.file.read("rom.gb"));
  immutable size_t romSize = rom.length;

  if (romSize == -1)
  {
    return cast(int32_t)(Result.FailedToOpenRomFile);
  }

  CPU.Reset();

  Interrupts.Reset();

  PPU.Reset();

  if (!Memory.LoadRom(&rom[0], romSize))
  {
    return cast(int32_t)(Result.FailedToLoadRom);
  }

  // Rom is copied to CPU memory, can be freed here

  TWM.Event event;

  while (true)
  {
    CPU.RunCycle();

    Interrupts.RunCycle();

    PPU.RunCycle();

    TWM.PollEvents(window, &event, 1);

    debug
    {
      printf("Num Cycles Executed: %d \n", CPU.GetTotalCyclesCount());
    }

    if(event == TWM.Event.Exit)
    {
      break;
    }
  }

  TWM.ShutdownWindow(window);

  return 0;
}
