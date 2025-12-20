import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import 'notification_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Create a new booking under user's bookings subcollection
  Future<String> createBooking(Booking booking) async {
    try {
      // Store in user's bookings subcollection
      final docRef = await _firestore
          .collection('users')
          .doc(booking.userId)
          .collection('bookings')
          .add(booking.toMap());

      print('✅ Booking created successfully for user ${booking.userId}: ${docRef.id}');
      
      // Send booking confirmation notification
      try {
        await _notificationService.sendBookingConfirmation(
          userId: booking.userId,
          eventTitle: booking.eventTitle,
          bookingId: docRef.id,
        );
      } catch (e) {
        print('⚠️ Error sending booking notification: $e');
        // Don't fail the booking if notification fails
      }
      
      return docRef.id;
    } catch (e) {
      print('❌ Error creating booking: $e');
      rethrow;
    }
  }

  // ✅ SIMPLIFIED: Get user's bookings (only orderBy, no where clause)
  Stream<List<Booking>> getUserBookings(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .orderBy('bookedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final booking = Booking.fromFirestore(doc);
        return Booking(
          id: doc.id,
          userId: booking.userId,
          userName: booking.userName,
          eventId: booking.eventId,
          eventTitle: booking.eventTitle,
          eventLocation: booking.eventLocation,
          eventDate: booking.eventDate,
          eventStartTime: booking.eventStartTime,
          numberOfTickets: booking.numberOfTickets,
          pricePerTicket: booking.pricePerTicket,
          totalAmount: booking.totalAmount,
          paymentMethod: booking.paymentMethod,
          bookingStatus: booking.bookingStatus,
          bookedAt: booking.bookedAt,
          qrCode: booking.qrCode,
        );
      }). toList();
    });
  }

  // Cancel a booking
  Future<void> cancelBooking(String userId, String bookingId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          . collection('bookings')
          . doc(bookingId)
          .update({
        'bookingStatus': 'cancelled',
      });
      print('✅ Booking cancelled successfully');
    } catch (e) {
      print('❌ Error cancelling booking: $e');
      rethrow;
    }
  }

  // Get single booking
  Future<Booking? > getBooking(String userId, String bookingId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (doc.exists) {
        final booking = Booking.fromFirestore(doc);
        return Booking(
          id: doc. id,
          userId: booking.userId,
          userName: booking.userName,
          eventId: booking.eventId,
          eventTitle: booking.eventTitle,
          eventLocation: booking.eventLocation,
          eventDate: booking. eventDate,
          eventStartTime: booking.eventStartTime,
          numberOfTickets: booking.numberOfTickets,
          pricePerTicket: booking.pricePerTicket,
          totalAmount: booking.totalAmount,
          paymentMethod: booking.paymentMethod,
          bookingStatus: booking.bookingStatus,
          bookedAt: booking.bookedAt,
          qrCode: booking.qrCode,
        );
      }
      return null;
    } catch (e) {
      print('❌ Error getting booking: $e');
      rethrow;
    }
  }

  // Get bookings for a specific event (across all users - optional, for analytics)
  Stream<List<Booking>> getEventBookings(String eventId) {
    // This requires a collection group query
    return _firestore
        . collectionGroup('bookings')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final booking = Booking. fromFirestore(doc);
        return Booking(
          id: doc.id,
          userId: booking.userId,
          userName: booking.userName,
          eventId: booking.eventId,
          eventTitle: booking.eventTitle,
          eventLocation: booking.eventLocation,
          eventDate: booking.eventDate,
          eventStartTime: booking.eventStartTime,
          numberOfTickets: booking. numberOfTickets,
          pricePerTicket: booking.pricePerTicket,
          totalAmount: booking.totalAmount,
          paymentMethod: booking.paymentMethod,
          bookingStatus: booking.bookingStatus,
          bookedAt: booking.bookedAt,
          qrCode: booking.qrCode,
        );
      }).toList();
    });
  }
}