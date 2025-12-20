import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';
import '../models/notification_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Add a single event
  Future<String> addEvent(Map<String, dynamic> eventData) async {
    try {
      final docRef = await _firestore.collection('events').add(eventData);
      print('✅ Event added successfully!');
      
      // Send notifications to followers about new event
      if (eventData['organizerId'] != null) {
        try {
          await _sendNewEventNotifications(
            organizerId: eventData['organizerId'],
            eventTitle: eventData['title'] ?? 'New Event',
            eventId: docRef.id, // Use the actual document ID
          );
        } catch (e) {
          print('⚠️ Error sending new event notifications: $e');
          // Don't fail event creation if notification fails
        }
      }
      
      return docRef.id;
    } catch (e) {
      print('❌ Error adding event: $e');
      rethrow;
    }
  }
  
  // Send notifications to followers about new event
  Future<void> _sendNewEventNotifications({
    required String organizerId,
    required String eventTitle,
    required String eventId,
  }) async {
    try {
      // Get organizer's followers
      final followersSnapshot = await _firestore
          .collection('users')
          .doc(organizerId)
          .collection('followers')
          .get();
      
      // Get organizer name
      final organizerDoc = await _firestore.collection('users').doc(organizerId).get();
      final organizerName = organizerDoc.data()?['displayName'] ?? 'An organizer';
      
      // Send notification to each follower
      for (var followerDoc in followersSnapshot.docs) {
        final followerId = followerDoc.data()['userId'];
        if (followerId != null) {
          await _notificationService.createNotification(
            NotificationModel(
              id: '',
              userId: followerId,
              type: 'new_event',
              title: 'New Event',
              message: '$organizerName created a new event: $eventTitle',
              createdAt: DateTime.now(),
              isRead: false,
              data: {
                'eventId': eventId,
                'organizerId': organizerId,
              },
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error sending new event notifications: $e');
      rethrow;
    }
  }

  // Seed multiple dummy events
  Future<void> seedDummyEvents() async {
    final List<Map<String, dynamic>> dummyEvents = [
      {
        'title': 'International Band Music Concert',
        'description': 'Enjoy your favorite dishes and a lovely your friends and family and have a great time. Food from local food trucks will be available for purchase.',
        'location': 'Gala Convention Center',
        'address': '36 Guild Street London, UK',
        'date': Timestamp.fromDate(DateTime(2024, 12, 14, 16, 0)),
        'day': '14',
        'month': 'December',
        'year': '2024',
        'startTime': '4:00PM',
        'endTime': '9:00PM',
        'organizerId': "currentUserId",
        'organizerName': 'Ashfak Sayem',
        'price': 120.0,
        'category': 'Music',
        'imageUrl': '',
        'attendees': 20,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'A Virtual Evening of Smooth Jazz',
        'description': 'Join us for an unforgettable evening of smooth jazz performed by world-class musicians. Relax and enjoy the soulful melodies.',
        'location': 'Radius Gallery',
        'address': 'Santa Cruz, CA',
        'date': Timestamp.fromDate(DateTime(2024, 5, 20, 19, 30)),
        'day': '20',
        'month': 'May',
        'year': '2024',
        'startTime': '7:30PM',
        'endTime': '10:00PM',
        'organizerId': "currentUserId",
        'organizerName': 'Ashfak Sayem',
        'price': 50.0,
        'category': 'Music',
        'imageUrl': '',
        'attendees': 15,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Jo Malone London\'s Mother\'s Day',
        'description': 'Celebrate Mother\'s Day with an exclusive event featuring Jo Malone London fragrances, gifts, and special offers.',
        'location': 'Radius Gallery',
        'address': 'Santa Cruz, CA',
        'date': Timestamp.fromDate(DateTime(2024, 5, 12, 14, 0)),
        'day': '12',
        'month': 'May',
        'year': '2024',
        'startTime': '2:00PM',
        'endTime': '6:00PM',
        'organizerId': "currentUserId",
        'organizerName': 'Tomorrowland',
        'price': 0.0,
        'category': 'Art',
        'imageUrl': '',
        'attendees': 30,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Summer Music Festival 2024',
        'description': 'Experience the biggest music festival of the summer with top artists from around the world. Multiple stages, food trucks, and more!',
        'location': 'Central Park',
        'address': 'New York, NY',
        'date': Timestamp.fromDate(DateTime(2024, 6, 20, 12, 0)),
        'day': '20',
        'month': 'June',
        'year': '2024',
        'startTime': '12:00PM',
        'endTime': '11:00PM',
        'organizerId': "currentUserId",
        'organizerName': 'Live Nation',
        'price': 150.0,
        'category': 'Music',
        'imageUrl': '',
        'attendees': 500,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Food & Wine Expo',
        'description': 'Taste exceptional wines and gourmet dishes from renowned chefs. A paradise for food lovers!',
        'location': 'Convention Center',
        'address': 'Chicago, IL',
        'date': Timestamp.fromDate(DateTime(2024, 6, 22, 18, 0)),
        'day': '22',
        'month': 'June',
        'year': '2024',
        'startTime': '6:00PM',
        'endTime': '10:00PM',
        'organizerId': "currentUserId",
        'organizerName': 'Culinary Events',
        'price': 85.0,
        'category': 'Food',
        'imageUrl': '',
        'attendees': 75,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Art Gallery Opening Night',
        'description': 'Celebrate the opening of our new contemporary art gallery featuring works from emerging artists.',
        'location': 'Downtown Gallery',
        'address': 'Los Angeles, CA',
        'date': Timestamp.fromDate(DateTime(2024, 6, 25, 19, 0)),
        'day': '25',
        'month': 'June',
        'year': '2024',
        'startTime': '7:00PM',
        'endTime': '9:00PM',
        'organizerId': "currentUserId",
        'organizerName': 'Modern Art Museum',
        'price': 0.0,
        'category': 'Art',
        'imageUrl': '',
        'attendees': 45,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Tech Conference 2024',
        'description': 'Join industry leaders and innovators for keynotes, workshops, and networking opportunities.',
        'location': 'Silicon Valley Convention Center',
        'address': 'San Jose, CA',
        'date': Timestamp.fromDate(DateTime(2024, 7, 10, 9, 0)),
        'day': '10',
        'month': 'July',
        'year': '2024',
        'startTime': '9:00AM',
        'endTime': '5:00PM',
        'organizerId': "currentUserId",
        'organizerName': 'Tech Events Inc',
        'price': 250.0,
        'category': 'Clubbing',
        'imageUrl': '',
        'attendees': 200,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Marathon for Charity',
        'description': 'Run for a cause! Join our annual charity marathon and help raise funds for children in need.',
        'location': 'City Stadium',
        'address': 'Boston, MA',
        'date': Timestamp.fromDate(DateTime(2024, 8, 5, 7, 0)),
        'day': '5',
        'month': 'August',
        'year': '2024',
        'startTime': '7:00AM',
        'endTime': '12:00PM',
        'organizerId': "currentUserId",
        'organizerName': 'Charity Runners',
        'price': 30.0,
        'category': 'Sports',
        'imageUrl': '',
        'attendees': 350,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    try {
      // Use batch write for better performance
      final batch = _firestore.batch();

      for (var eventData in dummyEvents) {
        final docRef = _firestore.collection('events').doc();
        batch.set(docRef, eventData);
      }

      await batch.commit();
      print('✅ Successfully seeded ${dummyEvents.length} dummy events!');
    } catch (e) {
      print('❌ Error seeding events: $e');
      rethrow;
    }
  }

  // Delete all events (use with caution!)
  Future<void> clearAllEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ All events cleared!');
    } catch (e) {
      print('❌ Error clearing events: $e');
      rethrow;
    }
  }
}