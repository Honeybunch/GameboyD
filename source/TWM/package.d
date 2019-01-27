module TWM;

version(Windows)
{
  public import TWM.Win32;
}

version (linux)
{
  public import TWM.X11;
}

version (OSX)
{
  public import TWM.Cocoa;
}