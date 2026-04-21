import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudStorage {
  static final _db = FirebaseFirestore.instance;

  /// 🟢 ИЗМЕНЕНО: Теперь принимает worldId и сохраняет прогресс конкретного мира
  static Future<void> saveProgress(String worldId, int totalSteps) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Сохраняем в путь: users / [UID] / worlds / [worldId]
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('worlds')
          .doc(worldId)
          .set({
        'totalSteps': totalSteps,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge: true чтобы не затереть другие поля, если они будут
    } catch (e) {
      print("CloudStorage Save Error: $e");
      // игнорируем ошибки (например нет интернета)
    }
  }

  /// 🟢 ИЗМЕНЕНО: Теперь принимает worldId и загружает прогресс конкретного мира
  static Future<int?> loadProgress(String worldId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await _db
          .collection('users')
          .doc(user.uid)
          .collection('worlds')
          .doc(worldId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data();
      return data?['totalSteps'] as int?;
    } catch (e) {
      print("CloudStorage Load Error: $e");
      return null;
    }
  }
}