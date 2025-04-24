import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const MaterialColor myBlue = MaterialColor(
  0xFF004AAD,
  <int, Color>{
    50: Color(0xFFE1E8F5),
    100: Color(0xFFB3C6E6),
    200: Color(0xFF81A3D6),
    300: Color(0xFF4F80C5),
    400: Color(0xFF2966B9),
    500: Color(0xFF004AAD),
    600: Color(0xFF0043A6),
    700: Color(0xFF003A9C),
    800: Color(0xFF003293),
    900: Color(0xFF002282),
  },
);

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final CollectionReference queues = FirebaseFirestore.instance.collection('queues');

  void _updateStatus(String docId, String newStatus) async {
    await queues.doc(docId).update({'status': newStatus});
  }

  void _deleteQueue(String docId) async {
    await queues.doc(docId).delete();
  }

  void _markAsNext(String currentDocId) async {
    // 1. Mark current as completed
    await queues.doc(currentDocId).update({'status': 'completed'});

    // 2. Find next in line (first one with status 'waiting')
    final nextQuery = await queues
        .where('status', isEqualTo: 'waiting')
        .orderBy('timestamp')
        .limit(1)
        .get();

    if (nextQuery.docs.isNotEmpty) {
      await queues.doc(nextQuery.docs.first.id).update({'status': 'serving'});
    }
  }

  double _calculateAvgWait(List<QueryDocumentSnapshot> docs) {
    final waitingDocs = docs.where((doc) => doc['status'] == 'waiting');
    if (waitingDocs.isEmpty) return 0;

    final now = DateTime.now();

    final totalMinutes = waitingDocs.map((doc) {
      final timestamp = (doc['timestamp'] as Timestamp).toDate();
      return now.difference(timestamp).inMinutes;
    }).reduce((a, b) => a + b);

    return totalMinutes / waitingDocs.length;
  }

  Widget _buildMetric(String label, String value, Color color) {
  // For standard MaterialColors (like Colors.red, Colors.orange)
  final textColor = color is MaterialColor ? color[800] : color;
  
  return Chip(
    backgroundColor: color.withOpacity(0.1),
    avatar: CircleAvatar(
      backgroundColor: color,
      child: Text(value[0], style: const TextStyle(color: Colors.white)),
    ),
    label: Text(
      "$label: $value",
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _buildStatsPanel(int total, int waiting, int serving, int completed, int missed, double avgWait) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📊 Queue Metrics",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: myBlue, // Use the MaterialColor here
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildMetric("Total", total.toString(), Colors.grey),
              _buildMetric("Waiting", waiting.toString(), Colors.orange),
              _buildMetric("Serving", serving.toString(), myBlue), // Use MaterialColor
              _buildMetric("Completed", completed.toString(), Colors.green),
              _buildMetric("Missed", missed.toString(), Colors.red),
              _buildMetric("Avg Wait", "${avgWait.toStringAsFixed(1)} min", Colors.purple),
            ],
          )
        ],
      ),
    ),
  );
}

  Widget _buildQueueCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'waiting';
    final service = data['service'] ?? 'Unknown Service';
    final ticket = data['ticketNumber'] ?? '--';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service + Ticket
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$service",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF004AAD),
                  ),
                ),
                Text(
                  "Ticket: #$ticket",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status
            Row(
              children: [
                const Text("Status: "),
                DropdownButton<String>(
                  value: status,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'waiting', child: Text("Waiting")),
                    DropdownMenuItem(value: 'serving', child: Text("Serving")),
                    DropdownMenuItem(value: 'completed', child: Text("Completed")),
                    DropdownMenuItem(value: 'missed', child: Text("Missed")),
                  ],
                  onChanged: (value) {
                    if (value != null) _updateStatus(doc.id, value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _markAsNext(doc.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF078C03),
                  ),
                  icon: const Icon(Icons.skip_next),
                  label: const Text("Next"),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // Placeholder for push notify
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notify action triggered")),
                    );
                  },
                  icon: const Icon(Icons.notifications_active),
                  label: const Text("Notify"),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _deleteQueue(doc.id),
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Queue Control Panel 🛠️"),
        centerTitle: true,
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: queues.orderBy('timestamp', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final queueList = snapshot.data!.docs;

          if (queueList.isEmpty) {
            return const Center(child: Text("No queues at the moment 🚫"));
          }

          final total = queueList.length;
          final waiting = queueList.where((doc) => doc['status'] == 'waiting').length;
          final serving = queueList.where((doc) => doc['status'] == 'serving').length;
          final completed = queueList.where((doc) => doc['status'] == 'completed').length;
          final missed = queueList.where((doc) => doc['status'] == 'missed').length;
          final avgWaitMinutes = _calculateAvgWait(queueList);

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _buildStatsPanel(total, waiting, serving, completed, missed, avgWaitMinutes),
              const SizedBox(height: 16),
              ...queueList.map((doc) => _buildQueueCard(doc)).toList(),
            ],
          );
        },
      ),
    );
  }
}