class DuesUser {
  final String firebaseUid;
  final String name;
  final String username;

  DuesUser(
      {required this.firebaseUid, required this.name, required this.username});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = <String, dynamic>{};
    m['firebaseUid'] = firebaseUid;
    m['name'] = name;
    m['username'] = username;
    return m;
  }

  bool isEqual(DuesUser check) {
    return firebaseUid == check.firebaseUid;
  }

  static DuesUser fromJson(Map<String, dynamic> m) {
    return DuesUser(
        firebaseUid: m['firebaseUid'],
        name: m['name'],
        username: m['username']);
  }
}
