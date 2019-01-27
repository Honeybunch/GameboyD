module twm.X11;

version (linux):

import std.stdint;

public import twm.common;

bool constructWindow(uint16_t width, uint16_t height, Window* window)
{
  return false;
}

void pollEvents(const Window* window, Event* events, size_t eventCount)
{

}

void shutdownWindow(Window* window)
{
}
