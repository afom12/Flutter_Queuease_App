import 'package:flutter/material.dart';
import 'package:queuease_app/services/queue_service.dart';

class ServiceSelectionPage extends StatefulWidget {
  const ServiceSelectionPage({super.key});

  @override
  State<ServiceSelectionPage> createState() => _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends State<ServiceSelectionPage> {
  final QueueService _queueService = QueueService();
  final List<String> _services = [
    "New Passport",
    "Renewal",
    "Visa Extension",
    "Immigration ID",
    "Document Authentication",
  ];

  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submitBooking() async {
    if (_selectedService != null && _selectedDate != null && _selectedTime != null) {
      try {
        await _queueService.bookService(
          service: _selectedService!,
          date: _selectedDate!,
          time: _selectedTime!.format(context),
        );

        Navigator.pushNamed(context, '/booking-confirmation', arguments: {
          "service": _selectedService,
          "date": _selectedDate,
          "time": _selectedTime,
        });
      } catch (e) {
        _showError("Error: ${e.toString()}");
      }
    } else {
      _showError("Please fill all fields");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a Service"),
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "👋🏽 Let's Get You in the Queue!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dropdown for Service
            const Text("Select a Service", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedService,
              items: _services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedService = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 24),

            // Date Picker
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Color(0xFF004AAD)),
              title: Text(
                _selectedDate == null
                    ? "Pick a preferred date"
                    : "${_selectedDate!.toLocal()}".split(' ')[0],
              ),
              onTap: _pickDate,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.white,
            ),
            const SizedBox(height: 12),

            // Time Picker
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xFF004AAD)),
              title: Text(
                _selectedTime == null
                    ? "Pick a preferred time"
                    : _selectedTime!.format(context),
              ),
              onTap: _pickTime,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.white,
            ),

            const SizedBox(height: 30),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitBooking,
                icon: const Icon(Icons.check_circle),
                label: const Text("Confirm Booking"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C2CB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
