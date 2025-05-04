import 'package:flutter/material.dart';
import 'package:management/model/payment_method.dart';


class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({Key? key}) : super(key: key);

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  // Mock payment methods
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      name: 'John Doe',
      number: '**** **** **** 1234',
      expiryDate: '12/25',
      cardType: 'Visa',
      image: 'assets/visa.png',
    ),
  
  ];

  int _selectedPaymentMethod = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = _paymentMethods[index];
                  return PaymentMethodCard(
                    paymentMethod: method,
                    isSelected: _selectedPaymentMethod == index,
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = index;
                      });
                    },
                    onEdit: () {
                      _editPaymentMethod(method);
                    },
                    onDelete: () {
                      _deletePaymentMethod(method);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _addNewPaymentMethod();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Add New Payment Method'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Process payment with selected method
                  _processPayment(_paymentMethods[_selectedPaymentMethod]);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continue to Payment',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AddPaymentMethodSheet(),
    );
  }

  void _editPaymentMethod(PaymentMethod method) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddPaymentMethodSheet(paymentMethod: method),
    );
  }

  void _deletePaymentMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete ${method.cardType} ending in ${method.number.substring(method.number.length - 4)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _paymentMethods.removeWhere((element) => element.id == method.id);
                if (_selectedPaymentMethod >= _paymentMethods.length) {
                  _selectedPaymentMethod = _paymentMethods.length - 1;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _processPayment(PaymentMethod method) {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading indicator
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Successful'),
          content: Text('Your payment using ${method.cardType} was processed successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PaymentMethodCard({
    Key? key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Card type image (placeholder)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    paymentMethod.cardType.substring(0, 1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Card details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod.cardType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paymentMethod.number,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (paymentMethod.expiryDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Expires: ${paymentMethod.expiryDate}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Selection indicator and actions
              Row(
                children: [
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddPaymentMethodSheet extends StatefulWidget {
  final PaymentMethod? paymentMethod;

  const AddPaymentMethodSheet({Key? key, this.paymentMethod}) : super(key: key);

  @override
  State<AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<AddPaymentMethodSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _cardNumberController;
  late TextEditingController _cardHolderController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;
  String _selectedCardType = 'Visa';

  @override
  void initState() {
    super.initState();
    final paymentMethod = widget.paymentMethod;
    _cardNumberController = TextEditingController(
        text: paymentMethod != null ? paymentMethod.number : '');
    _cardHolderController = TextEditingController(
        text: paymentMethod != null ? paymentMethod.name : '');
    _expiryController = TextEditingController(
        text: paymentMethod != null ? paymentMethod.expiryDate : '');
    _cvvController = TextEditingController();
    if (paymentMethod != null) {
      _selectedCardType = paymentMethod.cardType;
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.paymentMethod != null
                      ? 'Edit Payment Method'
                      : 'Add New Payment Method',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Card Type Selection
                  DropdownButtonFormField<String>(
                    value: _selectedCardType,
                    decoration: const InputDecoration(
                      labelText: 'Card Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Visa',
                        child: Text('Visa'),
                      ),
                      DropdownMenuItem(
                        value: 'Mastercard',
                        child: Text('Mastercard'),
                      ),
                      DropdownMenuItem(
                        value: 'American Express',
                        child: Text('American Express'),
                      ),
                      DropdownMenuItem(
                        value: 'PayPal',
                        child: Text('PayPal'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCardType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Card Number Field
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter card number';
                      }
                      if (_selectedCardType != 'PayPal' && value.length < 16) {
                        return 'Please enter a valid card number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Card Holder Name Field
                  TextFormField(
                    controller: _cardHolderController,
                    decoration: const InputDecoration(
                      labelText: 'Card Holder Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter cardholder name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Two fields in a row: Expiry Date and CVV
                  if (_selectedCardType != 'PayPal')
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryController,
                            decoration: const InputDecoration(
                              labelText: 'Expiry Date (MM/YY)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.datetime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              // Simple validation for MM/YY format
                              if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                                return 'Use MM/YY format';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (value.length < 3) {
                                return 'Invalid CVV';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Save payment method logic would go here
                          Navigator.pop(context);
                          
                          // In a real app, you would save the payment method to your state or database
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.paymentMethod != null
                                    ? 'Payment method updated successfully'
                                    : 'Payment method added successfully',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.paymentMethod != null ? 'Update' : 'Save',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}