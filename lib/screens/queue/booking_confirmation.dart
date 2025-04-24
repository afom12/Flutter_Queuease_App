import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    final String service = args['service'] ?? 'Unknown Service';
    final DateTime date = args['date'] ?? DateTime.now();
    final TimeOfDay time = args['time'] ?? const TimeOfDay(hour: 9, minute: 0);

    final String formattedDate = DateFormat.yMMMMd().format(date);
    final String formattedTime = time.format(context);

    final String ticketNumber = "Q-${DateTime.now().millisecondsSinceEpoch % 1000}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Confirmation"),
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            shadowColor: Colors.blueAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, size: 80, color: Color(0xFF078C03)),
                  const SizedBox(height: 16),
                  const Text(
                    "Booking Confirmed!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Thank you for booking with Ethiopian Immigration.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Divider(height: 30, thickness: 1),

                  _buildRow("Service", service),
                  _buildRow("Date", formattedDate),
                  _buildRow("Time", formattedTime),
                  _buildRow("Ticket Number", ticketNumber),
                  _buildRow("Status", "Waiting"),

                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Download not implemented")),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Download Ticket"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004AAD),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                    child: const Text("Back to Dashboard"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Color(0xFF004AAD))),
        ],
      ),
    );
  }
}
