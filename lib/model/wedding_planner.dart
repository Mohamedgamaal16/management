class EventPlanner {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final double price;
  final String location;
  final String city;
  final String overView;
  final List<String> eventTypes;
  final bool isPlanner;


  EventPlanner({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.location,
    required this.city,
    required this.eventTypes,
    required this.overView,
    this.isPlanner = false,
  });
}