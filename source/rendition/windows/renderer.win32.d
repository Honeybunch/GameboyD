module rendition.win32;

version(Windows):

import std.stdint;

import core.sys.windows.windows; // windows.h

void Present(void* deviceContext, uint8_t* rgbImage, uint16_t width, uint16_t height)                 
{
}