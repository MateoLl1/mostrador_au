import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/config/router/app_router.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

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
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Mostrador AU',
      debugShowCheckedModeBanner: false,
      theme: appTheme.theme(),
      routerConfig: appRouter,
    );
  }
}
