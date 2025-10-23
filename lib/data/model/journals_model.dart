class JournalEntry {
  final DateTime date;
  final num mood;
  final String note;

  JournalEntry({required this.date, required this.mood, required this.note});

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      note: json['note'],
    );
  }
}
