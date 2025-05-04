import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new booking
  Future<void> createBooking({
    required String plannerId,
    required String plannerName,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required DateTime bookingDate,
    required int guestCount,
    required double totalAmount,
    String? notes,
  }) async {
    try {
      // Get current user if logged in
      String? userId = _auth.currentUser?.uid;
      
      // Create booking document
      await _firestore.collection('bookings').add({
        'plannerId': plannerId,
        'plannerName': plannerName,
        'userId': userId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'bookingDate': Timestamp.fromDate(bookingDate),
        'guestCount': guestCount,
        'totalAmount': totalAmount,
        'notes': notes ?? '',
        'status': 'pending', // Initial status (pending, confirmed, completed, cancelled)
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Get bookings for the current user
  Future<List<Map<String, dynamic>>> getUserBookings() async {
    try {
      final String? userId = _auth.currentUser?.uid;
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      final QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('bookingDate', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  // Get bookings for a planner
  Future<List<Map<String, dynamic>>> getPlannerBookings(String plannerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('plannerId', isEqualTo: plannerId)
          .orderBy('bookingDate', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get planner bookings: $e');
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancellationReason': reason ?? '',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Get a specific booking by ID
  Future<Map<String, dynamic>> getBookingById(String bookingId) async {
    try {
      final DocumentSnapshot doc = 
          await _firestore.collection('bookings').doc(bookingId).get();
      
      if (!doc.exists) {
        throw Exception('Booking not found');
      }
      
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }
}