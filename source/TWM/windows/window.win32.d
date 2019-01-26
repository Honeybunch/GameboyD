module TWMWin32;

version (Windows)

import core.runtime;
import std.string;
import std.utf;
import std.stdint;

import core.sys.windows.windows; // windows.h

public import TWM;

pragma(lib, "gdi32.lib");
pragma(lib, "winmm.lib");

auto toUTF16z(S)(S s)
{
  return toUTFz!(const(wchar)*)(s);
}

extern(Windows)
LRESULT WindowCallback(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) nothrow
{
  switch (message)
  {
  case WM_DESTROY:
    PostQuitMessage(0);
    break;
  default:
    return DefWindowProc(hwnd, message, wParam, lParam);
  }

  return 0;
}

bool ConstructWindow(uint16_t width, uint16_t height, Window* window)
{
  HINSTANCE hInstance = GetModuleHandle(null);
  string win32ClassName = "TWMWWindow";

  WNDCLASS wndclass;

  wndclass.style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
  wndclass.lpfnWndProc = &WindowCallback;
  wndclass.cbClsExtra = 0;
  wndclass.cbWndExtra = 0;
  wndclass.hInstance = hInstance;
  wndclass.hIcon = LoadIcon(hInstance, IDI_APPLICATION);
  wndclass.hCursor = LoadCursor(null, IDC_ARROW);
  wndclass.hbrBackground = cast(HBRUSH)GetStockObject(WHITE_BRUSH);
  wndclass.lpszMenuName = null;
  wndclass.lpszClassName = win32ClassName.toUTF16z;

  if (!RegisterClass(&wndclass))
  {
    return false;
  }

  HWND hWnd = CreateWindow(win32ClassName.toUTF16z, "GameboyD", WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, CW_USEDEFAULT, width, height, null, null, hInstance, null);

  if (!hWnd)
  {
    return false;
  }

  HDC hDC = GetDC(hWnd);

  // Set the proper framebuffer settings
  PIXELFORMATDESCRIPTOR pfd = {
    PIXELFORMATDESCRIPTOR.sizeof, 1, PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER, // Flags
      PFD_TYPE_RGBA, // The kind of framebuffer. RGBA or palette.
      32, // Colordepth of the framebuffer.
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, // Number of bits for the depthbuffer
      8, // Number of bits for the stencilbuffer
      0, // Number of Aux buffers in the framebuffer.
      PFD_MAIN_PLANE, 0, 0, 0, 0
  };

  int pixelFormat = ChoosePixelFormat(hDC, &pfd);
  if (pixelFormat < 1)
  {
    return false;
  }
  if (!SetPixelFormat(hDC, pixelFormat, &pfd))
  {
    return false;
  }

  ShowWindow(hWnd, SW_SHOW);

  // Malloc some space for the window and display objects we need to track
  window.m_display = new HDC();
  window.m_window = new HWND();

  *(cast(HDC*) window.m_display) = hDC;
  *(cast(HWND*) window.m_window) = hWnd;

  return true;
}

void PollEvents(const Window* window, Event* events, size_t eventCount)
{
  MSG msg;
  PeekMessage(&msg, null, 0, 0, PM_REMOVE);

  TranslateMessage(&msg);
  DispatchMessage(&msg);

  if (eventCount == 0)
  {
    return;
  }

  switch (msg.message)
  {
  case WM_QUIT:
  case WM_CLOSE:
    events[0] = Event.Exit;
    break;
  default:
    events[0] = Event.None;
    break;
  }
}

void ShutdownWindow(Window* window)
{
  DestroyWindow(*cast(HWND*)(window.m_window));

  (*cast(HWND*) window.m_window).destroy();
  (*cast(HDC*) window.m_display).destroy();
}
