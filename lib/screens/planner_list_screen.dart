import 'package:flutter/material.dart';
import 'package:management/model/wedding_planner.dart';
import 'package:management/screens/planner_detailes_screen.dart';
import 'package:management/service/seddinservice.dart';

class PlannerListScreen extends StatefulWidget {
  const PlannerListScreen({Key? key}) : super(key: key);

  @override
  State<PlannerListScreen> createState() => _PlannerListScreenState();
}

class _PlannerListScreenState extends State<PlannerListScreen> {
  final WeddingPlannerService _plannerService = WeddingPlannerService();
  List<EventPlanner> _planners = [];
  bool _isLoading = true;
  String? _selectedCity;
  String? _selectedEventType;
  String _searchQuery = '';
  
  // List of available cities and event types
  List<String> _cities = [];
  List<String> _eventTypes = [];

  @override
  void initState() {
    super.initState();
    _loadPlanners();
  }

  Future<void> _loadPlanners() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get only accepted planners
      final planners = await _plannerService.getAllWeddingPlanners(showOnlyAccepted: true);
      
      // Extract unique cities and event types
      final Set<String> cities = {};
      final Set<String> eventTypes = {};
      
      for (final planner in planners) {
        if (planner.city.isNotEmpty) {
          cities.add(planner.city);
        }
        
        for (final eventType in planner.eventTypes) {
          if (eventType.isNotEmpty) {
            eventTypes.add(eventType);
          }
        }
      }
      
      setState(() {
        _planners = planners;
        _cities = cities.toList()..sort();
        _eventTypes = eventTypes.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading planners: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading planners: $e')),
        );
      }
    }
  }

  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final filteredPlanners = await _plannerService.getWeddingPlannersByFilter(
        city: _selectedCity,
        eventType: _selectedEventType,
        searchText: _searchQuery.isNotEmpty ? _searchQuery : null,
        showOnlyAccepted: true,
      );
      
      setState(() {
        _planners = filteredPlanners;
        _isLoading = false;
      });
    } catch (e) {
      print('Error applying filters: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying filters: $e')),
        );
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCity = null;
      _selectedEventType = null;
      _searchQuery = '';
    });
    _loadPlanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wedding Planners'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search planners...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                if (value.isEmpty || value.length > 2) {
                  _applyFilters();
                }
              },
            ),
          ),
          
          // Active filters
          if (_selectedCity != null || _selectedEventType != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Filters: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (_selectedCity != null)
                    Chip(
                      label: Text(_selectedCity!),
                      onDeleted: () {
                        setState(() {
                          _selectedCity = null;
                        });
                        _applyFilters();
                      },
                    ),
                  const SizedBox(width: 8),
                  if (_selectedEventType != null)
                    Chip(
                      label: Text(_selectedEventType!),
                      onDeleted: () {
                        setState(() {
                          _selectedEventType = null;
                        });
                        _applyFilters();
                      },
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset All'),
                  ),
                ],
              ),
            ),
          
          // Planners list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _planners.isEmpty
                    ? const Center(child: Text('No planners found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _planners.length,
                        itemBuilder: (context, index) {
                          final planner = _planners[index];
                          return _buildPlannerCard(planner);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannerCard(EventPlanner planner) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlannerDetailScreen(planner: planner),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Planner image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    planner.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      );
                    },
                  ),
                ),
                // Price tag
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${planner.price.toInt()} OMR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Planner info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planner.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        planner.city,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            planner.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (planner.eventTypes.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: planner.eventTypes
                          .take(3)
                          .map((type) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // City filter
                        const Text(
                          'City',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _cities.map((city) {
                            final isSelected = city == _selectedCity;
                            return ChoiceChip(
                              label: Text(city),
                              selected: isSelected,
                              selectedColor: Colors.black,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCity = selected ? city : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        
                        // Event type filter
                        const Text(
                          'Event Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _eventTypes.map((type) {
                            final isSelected = type == _selectedEventType;
                            return ChoiceChip(
                              label: Text(type),
                              selected: isSelected,
                              selectedColor: Colors.black,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedEventType = selected ? type : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        
                        // Apply filters button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _applyFilters();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Reset filters button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCity = null;
                                _selectedEventType = null;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Reset Filters',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}