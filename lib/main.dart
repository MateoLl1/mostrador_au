import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:mostrador_au/config/config.dart';
import 'package:mostrador_au/config/router/app_router.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  if (_esEscritorio) {
    await windowManager.ensureInitialized();
    // Intercepta el cierre (la X del sistema, Alt+F4) para poder cerrar la
    // sesión antes de salir — si no, onWindowClose nunca se dispara.
    await windowManager.setPreventClose(true);
  }

  final savedSession = await SessionStorage.load();

  runApp(
    ProviderScope(
      overrides: [
        appSessionProvider.overrideWith(
          (ref) => AppSessionNotifier(initialSession: savedSession),
        ),
      ],
      child: const MainApp(),
    ),
  );

  TaskbarService.instance.init();
}

bool get _esEscritorio =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux);

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    if (_esEscritorio) windowManager.addListener(this);
  }

  @override
  void dispose() {
    if (_esEscritorio) windowManager.removeListener(this);
    super.dispose();
  }

  // Se dispara con la X del sistema, Alt+F4 o el cierre del taskbar — no con
  // el botón "Cerrar sesión" del menú, que ya hace esto mismo y sigue en la
  // app. setPreventClose deja la ventana abierta hasta que llamemos destroy,
  // así el usuario no ve la ventana cerrarse mientras la sesión todavía se
  // está dando de baja en el servidor.
  //
  // El timeout es el tope: si Keycloak o la API tardan (auth.autoconsa.com
  // es un servidor externo, no local, así que un refresco de token ahí puede
  // pesar más que la llamada en sí), la ventana igual cierra a tiempo. Vale
  // la pena revisar los tiempos que imprime si esto se sigue sintiendo lento.
  @override
  void onWindowClose() async {
    final estaPrevinieno = await windowManager.isPreventClose();
    if (!estaPrevinieno) return;

    final reloj = Stopwatch()..start();

    if (ref.read(appSessionProvider) != null) {
      try {
        await Future.wait([
          ref.read(disponibilidadProvider.notifier).desactivar(),
          ref.read(appSessionProvider.notifier).clearSession(),
        ]).timeout(const Duration(seconds: 2));
      } catch (_) {
        // Se agotó el tiempo o falló la red: se cierra igual, no se deja al
        // usuario esperando por una sesión que de todas formas expira sola.
      }
    }

    debugPrint('[cierre] desactivar+clearSession tomó ${reloj.elapsedMilliseconds}ms');
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Mostrador AU',
      debugShowCheckedModeBanner: false,
      theme: appTheme.theme(),
      routerConfig: appRouter,
    );
  }
}
