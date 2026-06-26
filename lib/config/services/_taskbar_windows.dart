import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
import 'taskbar_service.dart';

// FLASHWINFO Win32 struct
final class _FlashInfo extends Struct {
  @Uint32()
  external int cbSize;
  @IntPtr()
  external int hwnd;
  @Uint32()
  external int dwFlags;
  @Uint32()
  external int uCount;
  @Uint32()
  external int dwTimeout;
}

typedef _FlashNative = Int32 Function(Pointer<_FlashInfo>);
typedef _FlashDart = int Function(Pointer<_FlashInfo>);
typedef _GetFgNative = IntPtr Function();
typedef _GetFgDart = int Function();
typedef _ShowWindowNative = Int32 Function(IntPtr hwnd, Int32 nCmdShow);
typedef _ShowWindowDart = int Function(int hwnd, int nCmdShow);
typedef _SetFgNative = Int32 Function(IntPtr hwnd);
typedef _SetFgDart = int Function(int hwnd);
typedef _BringTopNative = Int32 Function(IntPtr hwnd);
typedef _BringTopDart = int Function(int hwnd);
typedef _GetWinThreadNative = Uint32 Function(IntPtr hwnd, Pointer<Uint32> lpProcId);
typedef _GetWinThreadDart = int Function(int hwnd, Pointer<Uint32> lpProcId);
typedef _GetCurThreadNative = Uint32 Function();
typedef _GetCurThreadDart = int Function();
typedef _AttachThreadNative = Int32 Function(Uint32 idAttach, Uint32 idAttachTo, Int32 fAttach);
typedef _AttachThreadDart = int Function(int idAttach, int idAttachTo, int fAttach);

const _kFlashwTray = 2;
const _kFlashwTimernofg = 12;
const _kSwRestore = 9;

class TaskbarPlatform implements TaskbarService {
  int _hwnd = 0;
  bool _initialized = false;
  _FlashDart? _flashWindowEx;
  _GetFgDart? _getForegroundWindow;
  _ShowWindowDart? _showWindow;
  _SetFgDart? _setForegroundWindow;
  _BringTopDart? _bringWindowToTop;
  _GetWinThreadDart? _getWindowThreadProcessId;
  _GetCurThreadDart? _getCurrentThreadId;
  _AttachThreadDart? _attachThreadInput;

  @override
  void init() {
    if (!Platform.isWindows || _initialized) return;
    _initialized = true;

    try {
      final user32 = DynamicLibrary.open('user32.dll');
      _flashWindowEx =
          user32.lookupFunction<_FlashNative, _FlashDart>('FlashWindowEx');
      _getForegroundWindow =
          user32.lookupFunction<_GetFgNative, _GetFgDart>('GetForegroundWindow');
      _showWindow =
          user32.lookupFunction<_ShowWindowNative, _ShowWindowDart>('ShowWindow');
      _setForegroundWindow =
          user32.lookupFunction<_SetFgNative, _SetFgDart>('SetForegroundWindow');
      _bringWindowToTop =
          user32.lookupFunction<_BringTopNative, _BringTopDart>('BringWindowToTop');
      _getWindowThreadProcessId =
          user32.lookupFunction<_GetWinThreadNative, _GetWinThreadDart>('GetWindowThreadProcessId');
      _attachThreadInput =
          user32.lookupFunction<_AttachThreadNative, _AttachThreadDart>('AttachThreadInput');
      final kernel32 = DynamicLibrary.open('kernel32.dll');
      _getCurrentThreadId =
          kernel32.lookupFunction<_GetCurThreadNative, _GetCurThreadDart>('GetCurrentThreadId');
    } catch (_) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hwnd = _getForegroundWindow?.call() ?? 0;
    });
  }

  @override
  void flashIfUnfocused() {
    if (!Platform.isWindows) return;
    if (_hwnd == 0 || _flashWindowEx == null || _getForegroundWindow == null) {
      return;
    }
    if (_getForegroundWindow!() == _hwnd) return;

    using((arena) {
      final info = arena<_FlashInfo>();
      info.ref
        ..cbSize = sizeOf<_FlashInfo>()
        ..hwnd = _hwnd
        ..dwFlags = _kFlashwTray | _kFlashwTimernofg
        ..uCount = 0
        ..dwTimeout = 0;
      _flashWindowEx!(info);
    });
  }

  @override
  void bringToForeground() {
    if (!Platform.isWindows) return;
    if (_hwnd == 0 ||
        _showWindow == null ||
        _setForegroundWindow == null ||
        _bringWindowToTop == null ||
        _getForegroundWindow == null ||
        _getWindowThreadProcessId == null ||
        _getCurrentThreadId == null ||
        _attachThreadInput == null) {
      return;
    }

    final fgHwnd = _getForegroundWindow!();
    if (fgHwnd == _hwnd) return;

    // AttachThreadInput trick: adjuntarse al hilo con foco actual para que
    // Windows permita el cambio de ventana activa desde un proceso en 2do plano.
    final fgThread = _getWindowThreadProcessId!(fgHwnd, Pointer.fromAddress(0));
    final myThread = _getCurrentThreadId!();
    final needAttach = fgThread != 0 && fgThread != myThread;

    if (needAttach) _attachThreadInput!(myThread, fgThread, 1);

    _showWindow!(_hwnd, _kSwRestore);
    _setForegroundWindow!(_hwnd);
    _bringWindowToTop!(_hwnd);

    if (needAttach) _attachThreadInput!(myThread, fgThread, 0);
  }
}
