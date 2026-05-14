class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? phone;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phone,
  });

  factory UserProfile.fromSupabase(Map<String, dynamic> metadata, String id, String email) {
    return UserProfile(
      id: id,
      email: email,
      fullName: metadata['full_name'] ?? email.split('@')[0],
      avatarUrl: metadata['avatar_url'],
      phone: metadata['phone'],
    );
  }

  Map<String, dynamic> toMetadata() {
    return {
      'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (phone != null) 'phone': phone,
    };
  }
}
