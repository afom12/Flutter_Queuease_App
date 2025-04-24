import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:queuease_app/services/queue_service.dart';

class DashboardPage extends StatefulWidget {
  final String userName;
  final String userRole;

  const DashboardPage({
    super.key,
    this.userName = "User",
    this.userRole = "user",
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final QueueService _queueService = QueueService();
  Map<String, dynamic>? currentBooking;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentBooking();
  }

  Future<void> _loadCurrentBooking() async {
    final booking = await _queueService.getCurrentBooking();
    if (!mounted) return;
    setState(() {
      currentBooking = booking;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == "admin";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "QUEUEASE",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF004AAD), Color(0xFF078C03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: Badge(
              smallSize: 8,
              backgroundColor: Colors.amber,
              child: const Icon(Icons.notifications, color: Colors.white),
            ),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(context),
            const SizedBox(height: 30),
            _buildQueueStatusCard(context),
            const SizedBox(height: 30),
            _buildServicesGrid(context),
            const SizedBox(height: 30),
            if (isAdmin) _buildAdminAccessButton(context),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AAD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.track_changes),
                label: const Text(
                  "Track My Queue",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pushNamed(context, '/queue-status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    final isAdmin = widget.userRole == "admin";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: isAdmin ? "🛡️ " : "👋 ",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28),
              ),
              TextSpan(
                text: isAdmin ? "Welcome Admin, ${widget.userName}" : "Hello, ${widget.userName}",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isAdmin ? Colors.redAccent : const Color(0xFF004AAD),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isAdmin
              ? "You have elevated privileges"
              : "Welcome to Ethiopian Immigration Services",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isAdmin ? Colors.red[50] : Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isAdmin ? Colors.red : Colors.blue),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isAdmin ? Icons.security : Icons.person,
                  color: isAdmin ? Colors.red : Colors.blue),
              const SizedBox(width: 10),
              Text(
                isAdmin ? 'Admin Mode' : 'User Mode',
                style: TextStyle(
                  color: isAdmin ? Colors.red : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQueueStatusCard(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentBooking == null) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.info, color: Colors.orange, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "You have no active bookings. Book a service to get started.",
                  style: TextStyle(color: Colors.orange[900]),
                ),
              )
            ],
          ),
        ),
      );
    }

    final String service = currentBooking?["service"] ?? "Unknown";
    final Timestamp timestamp = currentBooking?["date"];
    final String time = currentBooking?["time"] ?? "--";
    final DateTime date = timestamp.toDate();

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: const Color(0xFF004AAD).withOpacity(0.2),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF004AAD), Color(0xFF078C03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.timer, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "CURRENT QUEUE STATUS",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.assignment_ind,
                              color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${date.toLocal().toString().split(' ')[0]} • $time",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF004AAD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/live-tracker'),
                          child: const Text("TRACK"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminAccessButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.admin_panel_settings),
        label: const Text("Admin Panel"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => Navigator.pushNamed(context, '/admin'),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      {
        'icon': Icons.add_circle_outline,
        'label': "Book Queue",
        'color': const Color(0xFF004AAD),
        'route': '/service-selection'
      },
      {
        'icon': Icons.location_on,
        'label': "Live Tracker",
        'color': const Color(0xFF078C03),
        'route': '/live-tracker'
      },
      {
        'icon': Icons.history,
        'label': "My History",
        'color': const Color(0xFFFFA000),
        'route': '/history'
      },
      {
        'icon': Icons.notifications,
        'label': "Notifications",
        'color': const Color(0xFF9C27B0),
        'route': '/notifications',
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: services.map((service) {
        return _buildServiceCard(
          icon: service['icon'] as IconData,
          label: service['label'] as String,
          color: service['color'] as Color,
          route: service['route'] as String,
        );
      }).toList(),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (label.length * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pushNamed(context, route),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
