import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;

  final void Function(String paymentId) onSuccess;
  final void Function(String error) onError;

  RazorpayService({
    required this.onSuccess,
    required this.onError,
  }) {
    _razorpay = Razorpay();

    // SUCCESS
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      (PaymentSuccessResponse response) {
        onSuccess(response.paymentId ?? '');
      },
    );

    // ERROR
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      (PaymentFailureResponse response) {
        onError(response.message ?? 'Payment failed');
      },
    );

    // WALLET (optional)
    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      (ExternalWalletResponse response) {},
    );
  }

  /// Open Razorpay checkout
  void openCheckout({
    required int amount, // in rupees
    required String name,
  }) {
    if (amount <= 0) {
      onError('Invalid amount');
      return;
    }

    final options = {
      'key': 'rzp_test_xxxxxxxxxx', // 🔥 PUT YOUR TEST KEY HERE
      'amount': amount * 100, // convert to paise
      'currency': 'INR',
      'name': name,
      'description': 'Order Payment',
      'timeout': 180,
      'retry': {
        'enabled': true,
        'max_count': 1,
      },
    };

    _razorpay.open(options);
  }

  /// Dispose when screen is closed
  void dispose() {
    _razorpay.clear();
  }
}
