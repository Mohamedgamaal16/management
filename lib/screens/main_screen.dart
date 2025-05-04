import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:management/model/wedding_planner.dart';
import 'package:management/screens/add_wedding_palnner_screen.dart';
import 'package:management/screens/planner_detailes_screen.dart';
import 'package:management/widgets/card.dart';

class WeddingPlannerSearchScreen extends StatefulWidget {
  const WeddingPlannerSearchScreen({Key? key}) : super(key: key);

  @override
  _WeddingPlannerSearchScreenState createState() =>
      _WeddingPlannerSearchScreenState();
}

class _WeddingPlannerSearchScreenState
    extends State<WeddingPlannerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filter variables
  String? selectedCity;
  String? selectedEventType;
  RangeValues priceRange = const RangeValues(0, 10000);
  bool showFilters = false;

  List<EventPlanner> weddingPlanners = [];
  List<EventPlanner> filteredPlanners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeddingPlanners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchWeddingPlanners() async {
    setState(() {
      isLoading = true;
    });

    try {

      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('wedding_planners').get();

      final List<EventPlanner> fetchedPlanners = [];

     for (var doc in snapshot.docs) {
  final data = doc.data() as Map<String, dynamic>;
  
  // Only include if isPlanner is true
  if (data['isPlanner'] == true) {
    fetchedPlanners.add(
      EventPlanner(
        id: doc.id,
        name: data['name'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        rating: (data['rating'] ?? 0).toDouble(),
        price: (data['price'] ?? 0).toDouble(),
        location: data['location'] ?? '',
        city: data['city'] ?? '',
        isPlanner: true,
        overView: data['overview'] ?? '',
        eventTypes: List<String>.from(data['eventTypes'] ?? []),
      ),
    );
  }
}

      setState(() {
        weddingPlanners = fetchedPlanners;
        filteredPlanners = fetchedPlanners;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching wedding planners: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void applyFilters() {
    setState(() {
      filteredPlanners =
          weddingPlanners.where((planner) {
            // Apply city filter
            if (selectedCity != null &&
                selectedCity!.isNotEmpty &&
                planner.city != selectedCity) {
              return false;
            }

            // Apply event type filter
            if (selectedEventType != null &&
                selectedEventType!.isNotEmpty &&
                !planner.eventTypes.contains(selectedEventType)) {
              return false;
            }

            // Apply price filter
            if (planner.price < priceRange.start ||
                planner.price > priceRange.end) {
              return false;
            }

            // Apply search text filter
            if (_searchController.text.isNotEmpty &&
                !planner.name.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                )) {
              return false;
            }

            return true;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Events Management',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search wedding planners...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showFilters
                              ? Icons.filter_list_off
                              : Icons.filter_list,
                        ),
                        onPressed: () {
                          setState(() {
                            showFilters = !showFilters;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => applyFilters(),
                  ),

                  // Filter options
                  if (showFilters)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // City filter
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedCity,
                            items: _getCityDropdownItems(),
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value;
                              });
                              applyFilters();
                            },
                          ),
                          const SizedBox(height: 16),

                          // Event type filter
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Event Type',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedEventType,
                            items: _getEventTypeDropdownItems(),
                            onChanged: (value) {
                              setState(() {
                                selectedEventType = value;
                              });
                              applyFilters();
                            },
                          ),
                          const SizedBox(height: 16),

                          // Price range filter
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price: \$${priceRange.start.toInt()} - \$${priceRange.end.toInt()}',
                              ),
                              RangeSlider(
                                values: priceRange,
                                min: 0,
                                max: 10000,
                                divisions: 20,
                                labels: RangeLabels(
                                  '\$${priceRange.start.toInt()}',
                                  '\$${priceRange.end.toInt()}',
                                ),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    priceRange = values;
                                  });
                                  applyFilters();
                                },
                              ),
                            ],
                          ),

                          // Reset filters button
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCity = null;
                                  selectedEventType = null;
                                  priceRange = const RangeValues(0, 10000);
                                  _searchController.clear();
                                });
                                applyFilters();
                              },
                              child: const Text('Reset Filters'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Wedding planner cards
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredPlanners.isEmpty
                      ? const Center(child: Text('No wedding planners found'))
                      : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 1.4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: filteredPlanners.length,
                        itemBuilder: (context, index) {
                          final planner = filteredPlanners[index];
                          return InkWell(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PlannerDetailScreen(
                                          planner: planner,
                                        ),
                                  ),
                                ),
                            child: WeddingPlannerCard(planner: planner),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality to upload new wedding planner
          _showAddWeddingPlannerDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getCityDropdownItems() {
    // Get unique cities from wedding planners
    final cities = weddingPlanners.map((p) => p.city).toSet().toList();
    cities.sort();

    final items =
        cities.map((city) {
          return DropdownMenuItem<String>(value: city, child: Text(city));
        }).toList();

    // Add "All" option
    items.insert(
      0,
      const DropdownMenuItem<String>(value: '', child: Text('All Cities')),
    );

    return items;
  }

  List<DropdownMenuItem<String>> _getEventTypeDropdownItems() {
    // Get unique event types from wedding planners
    final eventTypes =
        weddingPlanners.expand((p) => p.eventTypes).toSet().toList();
    eventTypes.sort();

    final items =
        eventTypes.map((type) {
          return DropdownMenuItem<String>(value: type, child: Text(type));
        }).toList();

    // Add "All" option
    items.insert(
      0,
      const DropdownMenuItem<String>(value: '', child: Text('All Event Types')),
    );

    return items;
  }

  void _showAddWeddingPlannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddWeddingPlannerDialog(),
    ).then((_) {
      // Refresh the list after adding a new planner
      fetchWeddingPlanners();
    });
  }
}
