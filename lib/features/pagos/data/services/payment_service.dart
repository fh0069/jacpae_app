/// Payment service placeholder
/// TODO PHASE 2: Implement real payment integration with Redsys
class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  /// Process payment - NOT IMPLEMENTED
  /// TODO PHASE 2: Implement real Redsys payment processing
  Future<bool> processPayment(String pagoId, double amount) async {
    throw UnimplementedError('TODO PHASE 2: Implement Redsys payment gateway');
  }

  /// Get payment status - NOT IMPLEMENTED
  /// TODO PHASE 2: Implement real payment status check
  Future<String> getPaymentStatus(String transactionId) async {
    throw UnimplementedError('TODO PHASE 2: Implement Redsys status check');
  }

  /// Cancel payment - NOT IMPLEMENTED
  /// TODO PHASE 2: Implement payment cancellation
  Future<void> cancelPayment(String transactionId) async {
    throw UnimplementedError('TODO PHASE 2: Implement payment cancellation');
  }
}
