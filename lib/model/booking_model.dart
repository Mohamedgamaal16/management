import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String plannerId;
  final String plannerName;
  final String? userId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final DateTime bookingDate;
  final int guestCount;
  final double totalAmount;
  final String notes;
  final String status;
  final DateTime createdAt;
  final String? cancellationReason;
  final DateTime? cancelledAt;

  Booking({
    required this.id,
    required this.plannerId,
    required this.plannerName,
    this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.bookingDate,
    required this.guestCount,
    required this.totalAmount,
    this.notes = '',
    required this.status,
    required this.createdAt,
    this.cancellationReason,
    this.cancelledAt,
  });

  // Create Booking from Firestore document
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Booking(
      id: doc.id,
      plannerId: data['plannerId'] ?? '',
      plannerName: data['plannerName'] ?? '',
      userId: data['userId'],
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      guestCount: data['guestCount'] ?? 0,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      notes: data['notes'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      cancellationReason: data['cancellationReason'],
      cancelledAt: data['cancelledAt'] != null 
          ? (data['cancelledAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convert Booking to a map
  Map<String, dynamic> toMap() {
    return {
      'plannerId': plannerId,
      'plannerName': plannerName,
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'guestCount': guestCount,
      'totalAmount': totalAmount,
      'notes': notes,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'cancellationReason': cancellationReason,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
    };
  }
}