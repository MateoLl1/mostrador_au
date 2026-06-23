import '_taskbar_stub.dart' if (dart.library.io) '_taskbar_windows.dart';

abstract class TaskbarService {
  static final TaskbarService instance = TaskbarPlatform();

  void init();
  void flashIfUnfocused();
}
