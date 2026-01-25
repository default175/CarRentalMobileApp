import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/cars/presentation/car_details_page.dart';
import '../../features/home/presentation/dashboard_page.dart';

GoRouter buildRouter(AuthController authController) {
  return GoRouter(
    initialLocation: '/register',
    refreshListenable: authController,
    routes: [
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/app',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/cars/:carId',
        builder: (context, state) => CarDetailsPage(
          carId: state.pathParameters['carId']!,
        ),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authController.isAuthenticated;
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';

      if (!isAuthenticated && !isLogin && !isRegister) {
        return '/register';
      }

      if (isAuthenticated && (isLogin || isRegister)) {
        return '/app';
      }

      return null;
    },
  );
}
