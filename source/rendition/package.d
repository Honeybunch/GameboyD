module rendition;

version(Windows)
{
  public import rendition.win32;
}

version (linux)
{
  public import rendition.x11;
}

version (OSX)
{
  public import rendition.cocoa;
}