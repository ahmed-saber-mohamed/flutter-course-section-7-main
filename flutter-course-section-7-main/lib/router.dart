import 'package:go_router/go_router.dart';

import 'home_page.dart';
import 'fav_page.dart';

final router = GoRouter(
  initialLocation: "/home",
  routes: [
    GoRoute(path: "/home", builder: (context, state) => const HomePage()),
    GoRoute(path: "/fav", builder: (context, state) => const FavPage()),
  ],
);
