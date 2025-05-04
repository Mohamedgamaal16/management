import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:management/model/wedding_planner.dart';

// Firebase service to handle wedding planner data
class WeddingPlannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all wedding planners
  Future<List<EventPlanner>> getAllWeddingPlanners({bool showOnlyAccepted = true}) async {
    Query query = _firestore
        .collection('wedding_planners')
        .orderBy('createdAt', descending: true);
    
    // Only show accepted planners if showOnlyAccepted is true
    if (showOnlyAccepted) {
      query = query.where('isPlanner', isEqualTo: true);
    }
    
    final QuerySnapshot snapshot = await query.get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return EventPlanner(
        id: doc.id,
        name: data['name'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        rating: (data['rating'] ?? 0).toDouble(),
        price: (data['price'] ?? 0).toDouble(),
        location: data['location'] ?? '',
        city: data['city'] ?? '',
        eventTypes: List<String>.from(data['eventTypes'] ?? []),
        isPlanner: data['isPlanner'] ?? false,
        overView: data['overview'] ?? '',
      );
    }).toList();
  }

  // Get wedding planners by filter
  Future<List<EventPlanner>> getWeddingPlannersByFilter({
    String? city,
    String? eventType,
    double? minPrice,
    double? maxPrice,
    String? searchText,
    bool showOnlyAccepted = true,
  }) async {
    Query query = _firestore.collection('wedding_planners');
    
    // Only show accepted planners if showOnlyAccepted is true
    if (showOnlyAccepted) {
      query = query.where('isPlanner', isEqualTo: true);
    }

    // Apply city filter
    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }

    // Apply price range filter
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    // Note: For eventType filter and searchText, we'll need to filter in memory
    // since Firestore doesn't support array-contains-any with other queries in the same composite index
    final QuerySnapshot snapshot = await query.get();
    
    List<EventPlanner> planners = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return EventPlanner(
        id: doc.id,
        name: data['name'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        rating: (data['rating'] ?? 0).toDouble(),
        price: (data['price'] ?? 0).toDouble(),
        location: data['location'] ?? '',
        city: data['city'] ?? '',
        eventTypes: List<String>.from(data['eventTypes'] ?? []),
        isPlanner: data['isPlanner'] ?? false, overView: data['overview'] ?? '',
      );
    }).toList();

    // Apply event type filter in memory
    if (eventType != null && eventType.isNotEmpty) {
      planners = planners
          .where((planner) => planner.eventTypes.contains(eventType))
          .toList();
    }

    // Apply search text filter in memory
    if (searchText != null && searchText.isNotEmpty) {
      final searchLower = searchText.toLowerCase();
      planners = planners
          .where(
            (planner) =>
                planner.name.toLowerCase().contains(searchLower) ||
                planner.location.toLowerCase().contains(searchLower),
          )
          .toList();
    }

    return planners;
  }
  Future<void> addWeddingPlanner({
    required String name,
    required double price,
    required String location,
    required String city,
    required double rating,
    required List<String> eventTypes,
    required String imageUrl,
    bool isPlanner = true,
    required String overiView
  }) async {
    await _firestore.collection('wedding_planners').add({
      'name': name,
      'price': price,
      'location': location,
      'city': city,
      'rating': rating,
      'imageUrl': imageUrl,
      'eventTypes': eventTypes,
      'isPlanner': true,
      'createdAt': FieldValue.serverTimestamp(),
      'overview':overiView
    });
  }
}