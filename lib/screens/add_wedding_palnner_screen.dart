import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:management/service/seddinservice.dart';

class AddWeddingPlannerDialog extends StatefulWidget {
  const AddWeddingPlannerDialog({Key? key}) : super(key: key);

  @override
  _AddWeddingPlannerDialogState createState() =>
      _AddWeddingPlannerDialogState();
}

class _AddWeddingPlannerDialogState extends State<AddWeddingPlannerDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _overviewController = TextEditingController();

  List<String> selectedEventTypes = [];
  double rating = 0;
  bool isLoading = false;

  final List<String> allEventTypes = [
    'Weddings',
    'Corporate Events',
    'Private Parties',
    'Trade Shows & Conventions',
    'Engagements & Family Events',
    'Sporting Events',
    'Academic & University Events',
    'Charity & Fundraising Events',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _uploadWeddingPlanner() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      WeddingPlannerService weddingPlannerService = WeddingPlannerService();
      await weddingPlannerService.addWeddingPlanner(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        location: _locationController.text.trim(),
        city: _cityController.text.trim(),
        rating: rating,
        imageUrl: _imageUrlController.text.trim(),
        eventTypes: selectedEventTypes,
        overiView: _overviewController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding wedding planner: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Wedding Planner'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _overviewController,
                decoration: const InputDecoration(
                  labelText: 'Overview',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Price field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // City field
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL field
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                  hintText: 'Enter direct image URL',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  if (!Uri.tryParse(value)!.isAbsolute) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rating field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rating'),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 30,
                    itemBuilder:
                        (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Event types field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Event Types'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        allEventTypes.map((type) {
                          final isSelected = selectedEventTypes.contains(type);
                          return FilterChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedEventTypes.add(type);
                                } else {
                                  selectedEventTypes.remove(type);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _uploadWeddingPlanner,
          child:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Add'),
        ),
      ],
    );
  }
}
