import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/payment.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Stripe (call this in main.dart)
  static Future<void> initializeStripe({
    required String publishableKey,
  }) async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  // Create a payment intent (in a real app, this should be done on the backend)
  // For demonstration, we'll use test mode
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    // In production, you should call your backend server to create the payment intent
    // This is a simplified version for demonstration
    // IMPORTANT: Never expose your Stripe secret key in the client app
    
    // For now, we'll return a mock payment intent
    // In a real app, you'd make an HTTP request to your backend
    return {
      'clientSecret': 'test_client_secret',
      'paymentIntentId': 'pi_test_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // Process payment
  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required String bookingId,
    required String eventId,
    required double amount,
    String currency = 'USD',
  }) async {
    try {
      // Create payment intent
      final paymentIntentData = await createPaymentIntent(
        amount: amount * 100, // Stripe uses cents
        currency: currency,
      );

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'EventHub',
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          style: ThemeMode.light,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful - create payment record
      final payment = Payment(
        id: '',
        userId: userId,
        bookingId: bookingId,
        eventId: eventId,
        amount: amount,
        currency: currency,
        paymentMethod: 'stripe',
        status: 'completed',
        stripePaymentIntentId: paymentIntentData['paymentIntentId'],
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      await _savePayment(payment);

      return {
        'success': true,
        'paymentId': payment.id,
      };
    } catch (e) {
      print('❌ Payment failed: $e');
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
