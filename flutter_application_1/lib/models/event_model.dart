// lib/models/event_model.dart

class Event {
  int? id;
  String eventName;
  String venue;
  String? address;
  DateTime dateTime;
  double? price;
  String status;
  String? contactName;
  String? contactPhone;
  String? notes;

  Event({
    this.id,
    required this.eventName,
    required this.venue,
    this.address,
    required this.dateTime,
    this.price,
    this.status = 'Confirmado',
    this.contactName,
    this.contactPhone,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventName,
      'venue': venue,
      'address': address,
      'dateTime': dateTime.toIso8601String(),
      'price': price,
      'status': status,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'notes': notes,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      eventName: map['eventName'],
      venue: map['venue'],
      address: map['address'],
      dateTime: DateTime.parse(map['dateTime']),
      price: map['price'],
      status: map['status'],
      contactName: map['contactName'],
      contactPhone: map['contactPhone'],
      notes: map['notes'],
    );
  }
}