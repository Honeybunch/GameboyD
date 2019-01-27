module twm.common;

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