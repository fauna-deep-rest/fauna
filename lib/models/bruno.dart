import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Bruno with ChangeNotifier {
  final String id;
  List<Record> records;
  List<String> summary;

  Bruno({
    required this.id,
    this.records = const [],
    this.summary = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'records': records.map((record) => record.toMap()).toList(),
      'summary': summary,
    };
  }

  factory Bruno.fromMap(Map<String, dynamic> map) {
    return Bruno(
      id: map['id'] ?? '',
      records: (map['records'] as List?)
              ?.map((record) => Record.fromMap(record))
              .toList() ??
          [],
      summary: List<String>.from(map['summary'] ?? []),
    );
  }

  void addSummary(String newSummary) {
    summary.add(newSummary);
    notifyListeners();
  }

  void clearSummary() {
    summary.clear();
    notifyListeners();
  }
}

class Record {
  final DateTime start;
  final DateTime end;
  final String type;

  Record({
    required this.start,
    required this.end,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'type': type,
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      start: (map['start'] as Timestamp).toDate(),
      end: (map['end'] as Timestamp).toDate(),
      type: map['type'] ?? '',
    );
  }
}
