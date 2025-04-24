import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 📦 Book a new service (stored under user's Firestore node)
  Future<void> bookService({
    required String service,
    required DateTime date,
    required String time,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final bookingData = {
      "service": service,
      "date": Timestamp.fromDate(date),
      "time": time,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    };

    await _db
        .collection("users")
        .doc(user.uid)
        .collection("bookings")
        .add(bookingData);
  }

  /// 📥 Fetch all pending bookings
  Future<List<Map<String, dynamic>>> getUserQueues() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final snapshot = await _db
        .collection("users")
        .doc(user.uid)
        .collection("bookings")
        .where("status", isEqualTo: "pending")
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs.map((doc) => {
          "id": doc.id,
          ...doc.data(),
        }).toList();
  }

  /// ✅ Mark a queue booking as completed → moves to history
  Future<void> completeBooking(String bookingId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final bookingRef = _db
        .collection("users")
        .doc(user.uid)
        .collection("bookings")
        .doc(bookingId);

    final bookingSnap = await bookingRef.get();
    if (!bookingSnap.exists) return;

    final bookingData = bookingSnap.data()!;
    bookingData["status"] = "completed";
    bookingData["completedAt"] = FieldValue.serverTimestamp();

    // Move to history collection
    await _db
        .collection("users")
        .doc(user.uid)
        .collection("history")
        .add(bookingData);

    // Remove from active bookings
    await bookingRef.delete();
  }

  /// 📜 Fetch user booking history
  Future<List<Map<String, dynamic>>> getBookingHistory() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final snapshot = await _db
        .collection("users")
        .doc(user.uid)
        .collection("history")
        .orderBy("completedAt", descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// 📍 Get user's current active booking (latest)
  Future<Map<String, dynamic>?> getCurrentBooking() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _db
        .collection("users")
        .doc(user.uid)
        .collection("bookings")
        .where("status", isEqualTo: "pending")
        .orderBy("createdAt", descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return {
      "id": snapshot.docs.first.id,
      ...snapshot.docs.first.data(),
    };
  }
}
