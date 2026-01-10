import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;

  final void Function() onSuccess;
  final void Function(String error) onError;

  RazorpayService({
    required this.onSuccess,
    required this.onError,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS, (_) => onSuccess());
    _razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR,
        (res) => onError(res.message ?? "Payment failed"));
  }

  void openCheckout({
    required int amount,
    required String orderId,
    required String name,
  }) {
    final options = {
      'key': 'RAZORPAY_KEY_HERE', // 🔥 PUT YOUR KEY
      'amount': amount * 100, // paise
      'name': name,
      'order_id': orderId,
      'currency': 'INR',
      'description': 'Order Payment',
      'prefill': {
        'contact': '9999999999',
        'email': 'demo@email.com',
      },
    };

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
