import 'package:car_rental_app/app/car_rental_app.dart';
import 'package:car_rental_app/core/services/local_app_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders registration screen', (tester) async {
    LocalAppStorage.instance.debugSeed(locationOnboardingSeen: true);

    await tester.pumpWidget(
      const ProviderScope(
        child: CarRentalApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });
}
