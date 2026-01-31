class User {
  final int? id;
  final String username;
  final String email;
  final String phone;
  final int level;
  final int currentXp;
  final int streak;

  User({
    this.id,
    required this.username,
    this.email = 'alex@focusguard.app', // Default for MVP
    this.phone = '+1 234 567 8900',     // Default for MVP
    this.level = 1,
    this.currentXp = 0,
    this.streak = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'level': level,
      'current_xp': currentXp,
      'streak': streak,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'] ?? 'alex@focusguard.app',
      phone: map['phone'] ?? '+1 234 567 8900',
      level: map['level'],
      currentXp: map['current_xp'],
      streak: map['streak'],
    );
  }
}
