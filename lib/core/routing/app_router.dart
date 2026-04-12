import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/auth/presentation/welcome_page.dart';
import '../../features/cars/presentation/car_details_page.dart';
import '../../features/extras/presentation/app_screen_catalog_page.dart';
import '../../features/home/presentation/dashboard_page.dart';

GoRouter buildRouter(AuthController authController) {
  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: authController,
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
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
      GoRoute(
        path: '/screens/:slug',
        builder: (context, state) => AppTemplateScreenPage(
          slug: state.pathParameters['slug']!,
          carId: state.uri.queryParameters['carId'],
        ),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authController.isAuthenticated;
      final isWelcome = state.matchedLocation == '/welcome';
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';
      final isPublicAuthScreen =
          state.matchedLocation.startsWith('/screens/') &&
              const {
                'reset-password',
                'otp',
                'resend-otp',
                'change-password',
              }.contains(state.pathParameters['slug']);

      if (!isAuthenticated &&
          !isWelcome &&
          !isLogin &&
          !isRegister &&
          !isPublicAuthScreen) {
        return '/welcome';
      }

      if (isAuthenticated && (isWelcome || isLogin || isRegister)) {
        return '/app';
      }

      return null;
    },
  );
}
