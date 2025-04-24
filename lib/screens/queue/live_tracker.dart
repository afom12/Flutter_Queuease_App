import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LiveQueueTracker extends StatefulWidget {
  const LiveQueueTracker({super.key});

  @override
  State<LiveQueueTracker> createState() => _LiveQueueTrackerState();
}

class _LiveQueueTrackerState extends State<LiveQueueTracker> {
  bool _loading = true;
  Map<String, dynamic>? _queueData;

  @override
  void initState() {
    super.initState();
    _fetchQueueStatus();
  }

  Future<void> _fetchQueueStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('queues')
          .doc(user.uid)
          .get();

      setState(() {
        _queueData = doc.data();
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching queue: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Queue Tracker"),
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _queueData == null
              ? const Center(child: Text("No queue found"))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🎫 Queue Number: ${_queueData!['queueNumber']}",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text("🛂 Service: ${_queueData!['service']}"),
                      Text("📍 Position in Queue: ${_queueData!['position']}"),
                      Text("⏳ Estimated Wait Time: ${_queueData!['waitTime']} minutes"),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchQueueStatus,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Refresh"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C2CB),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
