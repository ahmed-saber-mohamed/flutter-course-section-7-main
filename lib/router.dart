import 'package:go_router/go_router.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'home_page.dart' as home;
import 'fav_page.dart' as favorites;

final router = GoRouter(
  initialLocation: '/home',

  redirect: (context, state) async {
    final currentUser = await AuthService.getCurrentUser();
    final loggedIn = currentUser != null;
    final isLoginPage = state.matchedLocation == '/login';

    if (!loggedIn && !isLoginPage) {
      return '/login';
    }

    if (loggedIn && isLoginPage) {
      return '/home';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const home.HomePage(),
    ),
    GoRoute(
      path: '/fav',
      builder: (context, state) => const favorites.FavPage(),
    ),
  ],
);