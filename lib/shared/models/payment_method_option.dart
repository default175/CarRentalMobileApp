class PaymentMethodOption {
  const PaymentMethodOption({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;

  static const defaults = [
    PaymentMethodOption(
      id: 'card-4242',
      title: 'Credit card',
      subtitle: 'Visa **** 4242',
    ),
    PaymentMethodOption(
      id: 'paypal',
      title: 'Paypal',
      subtitle: 'Connected',
    ),
    PaymentMethodOption(
      id: 'google_pay',
      title: 'Google Pay',
      subtitle: 'Android wallet',
    ),
  ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
      };

  factory PaymentMethodOption.fromJson(Map<String, dynamic> json) {
    return PaymentMethodOption(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
    );
  }
}
