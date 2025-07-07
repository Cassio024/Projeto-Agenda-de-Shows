// lib/models/event_model.dart
class Event {
  final String id;
  final String userId;
  final String eventName;
  final String venue;
  final DateTime dateTime;

  Event({
    required this.id,
    required this.userId,
    required this.eventName,
    required this.venue,
    required this.dateTime,
  });

  // Construtor para criar um Event a partir do JSON da API
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'], // MongoDB usa _id
      userId: json['userId'],
      eventName: json['eventName'],
      venue: json['venue'],
      dateTime: DateTime.parse(json['dateTime']),
    );
  }
}