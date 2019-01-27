import std.stdint;
import std.file;
import core.stdc.stdio;

import cpu;
import ppu;
import interrupts;
import memory;
import twm;
import rendition;

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
  twm.Window* window = new twm.Window();
  twm.constructWindow(ppu.ScreenWidth * 4, ppu.ScreenHeight * 4, window);

  uint8_t[] rom = cast(uint8_t[])(std.file.read("rom.gb"));
  immutable size_t romSize = rom.length;

  if (romSize == -1)
  {
    return cast(int32_t)(Result.FailedToOpenRomFile);
  }

  cpu.Reset();

  interrupts.Reset();

  ppu.Reset();

  if (!memory.LoadRom(&rom[0], romSize))
  {
    return cast(int32_t)(Result.FailedToLoadRom);
  }

  // Rom is copied to CPU memory, can be freed here

  twm.Event event;

  while (true)
  {
    cpu.RunCycle();

    interrupts.RunCycle();

    ppu.RunCycle();

    twm.pollEvents(window, &event, 1);

    rendition.Present(window.m_display, null, 0, 0);

    debug
    {
      printf("Num Cycles Executed: %d \n", cpu.GetTotalCyclesCount());
    }

    if(event == twm.Event.Exit)
    {
      break;
    }
  }

  twm.shutdownWindow(window);

  return 0;
}
