module Platform;

void debugBreak()
{
  debug
  {
    version (X86_64)
    {
      asm{ int 3; }
    }

    version (X86)
    {
      asm { int 3; }
    }
  }
}
