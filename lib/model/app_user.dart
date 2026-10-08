import 'package:cloud_firestore/cloud_firestore.dart';

/// เอกสารใน collection users: uid, name, email, role ('Admin' หรือ 'Operator')
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  String get roleLabel => isAdmin ? 'Admin' : 'Operator';

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      role: d['role'] ?? 'Operator',
    );
  }
}
