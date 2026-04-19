import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/app_providers.dart';

class LocationAccessGate extends ConsumerWidget {
  const LocationAccessGate({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationAccessControllerProvider);
    final controller = ref.read(locationAccessControllerProvider.notifier);

    if (!state.shouldShowOnboarding) {
      return child;
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_searching_rounded,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Enable geodata',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Location access is required to use the app, show your city in the menu and place rented cars on the GPS map near you.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: state.requestInProgress
                          ? null
                          : controller.requestAccess,
                      icon: const Icon(Icons.my_location),
                      label: Text(
                        state.requestInProgress
                            ? 'Requesting permission...'
                            : 'Connect geodata',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'If permission is denied, enable location access in Android settings and try again.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
