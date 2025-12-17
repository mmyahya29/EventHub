import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simplified payment - no actual payment processing
  // Just creates a payment record for tracking purposes
  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required String bookingId,
    required String eventId,
    required double amount,
    String currency = 'USD',
  }) async {
    try {
      // Create payment record without actual payment processing
      final payment = Payment(
        id: '',
        userId: userId,
        bookingId: bookingId,
        eventId: eventId,
        amount: amount,
        currency: currency,
        paymentMethod: 'direct',
        status: 'completed',
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      await _savePayment(payment);

      return {
        'success': true,
        'paymentId': payment.id,
      };
    } catch (e) {
      print('❌ Payment record creation failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Save payment to Firestore
  Future<String> _savePayment(Payment payment) async {
    try {
      final docRef = await _firestore
          .collection('payments')
          .add(payment.toMap());
      
      print('✅ Payment saved: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error saving payment: $e');
      rethrow;
    }
  }

  // Get payment by booking ID
  Future<Payment?> getPaymentByBookingId(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Payment.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting payment: $e');
      return null;
    }
  }

  // Get user's payments
  Stream<List<Payment>> getUserPayments(String userId) {
    return _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Payment.fromFirestore(doc))
          .toList();
    });
  }

  // For test mode - simulate payment without Stripe
  Future<Map<String, dynamic>> simulatePayment({
    required String userId,
    required String bookingId,
    required String eventId,
    required double amount,
    String currency = 'USD',
  }) async {
    try {
      // Create a test payment record
      final payment = Payment(
        id: '',
        userId: userId,
        bookingId: bookingId,
        eventId: eventId,
        amount: amount,
        currency: currency,
        paymentMethod: 'test',
        status: 'completed',
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        metadata: {'test': true},
      );

      await _savePayment(payment);

      return {
        'success': true,
        'paymentId': payment.id,
      };
    } catch (e) {
      print('❌ Simulated payment failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
