class AppUser {
  final String uid;
  final String? email;
  final String? displayName;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
  });

  /// ✅ Create AppUser from Firestore map
  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
    );
  }

  /// ✅ Convert AppUser to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
    };
  }
}
