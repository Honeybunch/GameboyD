module TWM.Cocoa;

version (OSX):

import std.stdint;

public import TWM.common;

bool ConstructWindow(uint16_t width, uint16_t height, Window* window)
{
  return false;
}

void PollEvents(const Window* window, Event* events, size_t eventCount)
{

}

void ShutdownWindow(Window* window)
{
}
