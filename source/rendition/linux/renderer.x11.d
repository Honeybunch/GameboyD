module rendition.x11;

version(linux):

import std.stdint;

void Present(void* deviceContext, uint8_t* rgbImage, uint16_t width, uint16_t height)                 
{
}