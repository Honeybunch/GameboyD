module TWM;

version(Windows)
{
  import TWMWin32;
}

import std.stdint;

struct Window
{
  void* m_display = null;
  void* m_window = null;
}

enum Event
{
  None = 0,
  Exit
}

bool ConstructWindow(uint16_t width, uint16_t height, Window* window)
{
  version(Windows)
  {
    return TWMWin32.ConstructWindow(width, height, window);
  }

  version(linux)
  {
    return false;
  }

  version(OSX)
  {
    return false;
  }
}

void PollEvents(const Window* window, Event* events, size_t eventCount)
{
  version(Windows)
  {
    TWMWin32.PollEvents(window, events, eventCount);
  }
}

void ShutdownWindow(Window* window)
{
  version(Windows)
  {
    TWMWin32.ShutdownWindow(window);
  }
}
