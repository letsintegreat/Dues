class DuesTransaction {
  final String fromUid;
  final String toUid;
  final int amount;
  final DateTime dateTime;

  DuesTransaction(
      {required this.fromUid,
      required this.toUid,
      required this.amount,
      required this.dateTime});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = {};
    m["fromUid"] = fromUid;
    m["toUid"] = toUid;
    m["amount"] = amount;
    m["dateTime"] = dateTime.toString();
    return m;
  }

  static DuesTransaction fromJson(Map<String, dynamic> m) {
    return DuesTransaction(
        fromUid: m["fromUid"],
        toUid: m["toUid"],
        amount: m["amount"],
        dateTime: DateTime.parse(m["dateTime"]));
  }
}
