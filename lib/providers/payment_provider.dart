import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_service.dart';
import '../models/payment.dart';

// Payment Service Provider
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

// User Payments Stream Provider
final userPaymentsProvider = StreamProvider.family<List<Payment>, String>(
  (ref, userId) {
    final service = ref.watch(paymentServiceProvider);
    return service.getUserPayments(userId);
  },
);

// Payment by Booking ID Provider
final paymentByBookingIdProvider = FutureProvider.family<Payment?, String>(
  (ref, bookingId) async {
    final service = ref.watch(paymentServiceProvider);
    return await service.getPaymentByBookingId(bookingId);
  },
);
