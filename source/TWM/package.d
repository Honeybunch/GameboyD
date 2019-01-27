module twm;

version(Windows)
{
  public import twm.win32;
}

version (linux)
{
  public import twm.x11;
}

version (OSX)
{
  public import twm.cocoa;
}