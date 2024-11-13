// participant.dart
class Participant {
  final String name;
  final String profileImageUrl;

  Participant({required this.name, required this.profileImageUrl});

  factory Participant.fromMap(Map<String, dynamic> data) {
    return Participant(
      name: data['name'] ?? 'Unknown',
      profileImageUrl: data['profileImageUrl'] ?? '',
    );
  }
}
