import 'package:go_router/go_router.dart';
import 'package:mostrador_au/presentation/screens/screens.dart';

  final appRouter =  GoRouter(
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MostradorScreen(),
      ),
    ],
  );
