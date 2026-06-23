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

const _kFlashwTray = 2;
const _kFlashwTimernofg = 12;

class TaskbarPlatform implements TaskbarService {
  int _hwnd = 0;
  bool _initialized = false;
  _FlashDart? _flashWindowEx;
  _GetFgDart? _getForegroundWindow;

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
}
