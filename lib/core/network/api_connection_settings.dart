class ApiConnectionSettings {
  const ApiConnectionSettings({
    required this.baseUrl,
    required this.enabled,
  });

  final String baseUrl;
  final bool enabled;

  bool get hasValidBaseUrl =>
      baseUrl.startsWith('http://') || baseUrl.startsWith('https://');

  bool get shouldUseBackend => enabled && hasValidBaseUrl;

  ApiConnectionSettings copyWith({
    String? baseUrl,
    bool? enabled,
  }) {
    return ApiConnectionSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      enabled: enabled ?? this.enabled,
    );
  }
}
