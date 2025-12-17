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

  // ⚠️ SECURITY WARNING: This method should NEVER be used in production!
  // Create a payment intent (MUST be done on a secure backend server)
  // 
  // PRODUCTION REQUIREMENTS:
  // 1. Create a backend API endpoint (e.g., Cloud Functions, Express, etc.)
  // 2. The backend should create the payment intent using Stripe's server-side SDK
  // 3. Never expose your Stripe secret key in the client app
  // 4. The client should only receive the client_secret from your backend
  // 
  // Example backend implementation (Node.js/Express):
  // ```javascript
  // app.post('/create-payment-intent', async (req, res) => {
  //   const paymentIntent = await stripe.paymentIntents.create({
  //     amount: req.body.amount,
  //     currency: req.body.currency,
  //   });
  //   res.json({ clientSecret: paymentIntent.client_secret });
  // });
  // ```
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    // TODO: Replace this with actual backend API call
    // This is a mock implementation for demonstration only
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
