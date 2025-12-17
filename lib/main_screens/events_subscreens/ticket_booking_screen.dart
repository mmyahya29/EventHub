import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';

class BookTicketScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> event;

  const BookTicketScreen({Key? key, required this.event}) : super(key: key);

  @override
  ConsumerState<BookTicketScreen> createState() => _BookTicketScreenState();
}

class _BookTicketScreenState extends ConsumerState<BookTicketScreen> {
  int _numberOfTickets = 1;
  String _selectedPaymentMethod = 'Credit Card';
  bool _isProcessing = false;

  final List<String> _paymentMethods = [
    'Credit Card',
    'Debit Card',
    'PayPal',
    'Apple Pay',
    'Google Pay',
  ];

  double get _pricePerTicket => (widget.event['price'] ?? 0.0).toDouble();

  double get _totalAmount => _pricePerTicket * _numberOfTickets;

  Future<void> _processBooking() async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) {
      _showSnackBar('Please sign in to book tickets', isError: true);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final bookingService = ref.read(bookingServiceProvider);

      final booking = Booking(
        id: '',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'User',
        eventId: widget.event['id'],
        eventTitle: widget.event['title'],
        eventLocation: widget.event['location'],
        eventDate: (widget.event['date'] as Timestamp).toDate(),
        eventStartTime: widget.event['startTime'],
        numberOfTickets: _numberOfTickets,
        pricePerTicket: _pricePerTicket,
        totalAmount: _totalAmount,
        paymentMethod: _selectedPaymentMethod,
        bookingStatus: 'confirmed',
        bookedAt: DateTime.now(),
      );

      await bookingService.createBooking(booking);

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showSnackBar('Error processing booking: $e', isError: true);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF00D9A5), size: 64),
            SizedBox(height: 16),
            Text(
              'Booking Successful! ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Your ticket${_numberOfTickets > 1 ? 's have' : ' has'} been booked successfully.  You can view your ticket${_numberOfTickets > 1 ? 's' : ''} in "My Tickets".',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to event details
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF5B4EFF))),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF5B4EFF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Ticket',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B4EFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event['title'] ?? 'Event Title',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.event['day']} ${widget.event['month']}, ${widget.event['year']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.event['startTime'] ?? 'Time',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.event['location'] ?? 'Location',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Number of Tickets
                  const Text(
                    'Number of Tickets',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tickets',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: _numberOfTickets > 1
                                      ? const Color(0xFF5B4EFF)
                                      : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              onPressed: _numberOfTickets > 1
                                  ? () {
                                      setState(() {
                                        _numberOfTickets--;
                                      });
                                    }
                                  : null,
                            ),
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                '$_numberOfTickets',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5B4EFF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _numberOfTickets++;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Payment Method
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._paymentMethods.map((method) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedPaymentMethod == method
                              ? const Color(0xFF5B4EFF)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: RadioListTile<String>(
                        value: method,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        title: Text(method),
                        activeColor: const Color(0xFF5B4EFF),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  // Price Summary
                  const Text(
                    'Price Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Price per ticket'),
                            Text(
                              '\$${_pricePerTicket.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Number of tickets'),
                            Text(
                              '$_numberOfTickets',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${_totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5B4EFF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Book Now Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: _isProcessing
                ? Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B4EFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _processBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4EFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'CONFIRM BOOKING - \$${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
