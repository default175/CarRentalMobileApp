import 'package:car_rental_app/app/car_rental_app.dart';
import 'package:car_rental_app/core/services/local_app_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('requires location before rendering app', (tester) async {
    LocalAppStorage.instance.debugSeed(locationOnboardingSeen: true);

    await tester.pumpWidget(
      const ProviderScope(
        child: CarRentalApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Enable geodata'), findsOneWidget);
    expect(find.text('Connect geodata'), findsOneWidget);
  });
}
